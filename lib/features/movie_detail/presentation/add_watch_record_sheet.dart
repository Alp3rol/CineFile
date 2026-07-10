import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

class AddWatchRecordSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> movieData;

  const AddWatchRecordSheet({super.key, required this.movieData});

  @override
  ConsumerState<AddWatchRecordSheet> createState() => _AddWatchRecordSheetState();
}

class _AddWatchRecordSheetState extends ConsumerState<AddWatchRecordSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  double _rating = 7.0;
  String _selectedMood = '🍿';
  int _episodeCount = 1;

  // "Aktif İzliyorum" episode tracking (TV only). _totalEpisodes comes from
  // TMDb; _isActivelyWatching/_lastWatchedEpisode are seeded once from the
  // show's persisted UserMovieSettings so this sheet remembers where the
  // user left off across separate watch records.
  int? _totalEpisodes;
  bool _isActivelyWatching = false;
  int? _lastWatchedEpisode;
  int _selectedEpisode = 1;
  bool _seededFromSettings = false;

  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _companionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<String> _moods = ['🍿', '😊', '😢', '😱', '😴', '🔥', '❤️'];

  final List<String> _placeSuggestions = ['Ev', 'Sinema', 'Arkadaşın Evi', 'Yolculukta'];
  final List<String> _companionSuggestions = ['Tek Başına', 'Arkadaşlarla', 'Ailemle', 'Sevgilimle'];
  final List<String> _tagSuggestions = ['#nostalji', '#sinemada', '#yalnız', '#aksiyon', '#romantizm'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _totalEpisodes = widget.movieData['number_of_episodes'] as int?;
  }

  // Seeds _isActivelyWatching/_lastWatchedEpisode from the show's persisted
  // UserMovieSettings exactly once, the first time that data is actually
  // available. Done in build() (not initState) because the native settings
  // provider is a Stream that may not have emitted yet on first mount —
  // reading ref.read(...).value there could silently see null even when a
  // row already exists in the database.
  void _seedFromSettingsIfNeeded() {
    if (_seededFromSettings || widget.movieData['media_type'] != 'tv') return;

    final tmdbId = widget.movieData['id'] as int;
    UserMovieSetting? existing;
    if (kIsWeb) {
      existing = ref.watch(webMovieSettingsProvider)[(tmdbId: tmdbId, isTv: true)];
    } else {
      final asyncSettings = ref.watch(movieSettingsProvider((tmdbId: tmdbId, isTv: true)));
      if (!asyncSettings.hasValue) return; // still loading — try again next build
      existing = asyncSettings.value;
    }

    _seededFromSettings = true;
    _isActivelyWatching = existing?.isActivelyWatching ?? false;
    _lastWatchedEpisode = existing?.lastWatchedEpisode;

    // Default to 1 episode per record — NOT the show's total episode count.
    // Defaulting to "all episodes" here would apply to every single record
    // added, so logging the same show 4 separate times would each count as
    // a full rewatch of the whole series (this caused a real bug: duration
    // stats ballooned to 1000+ hours). The user can still raise it manually
    // via the stepper for a genuine "watched the whole thing in one sitting"
    // entry.
    _episodeCount = 1;
    if (_isActivelyWatching) {
      final next = (_lastWatchedEpisode ?? 0) + 1;
      _selectedEpisode = _totalEpisodes != null ? next.clamp(1, _totalEpisodes!) : next;
    } else {
      _episodeCount = _totalEpisodes ?? 1;
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    _companionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // A movie/show can't have been watched before it was released. Falls back
  // to a wide-open range if the release date is missing or unparsable.
  DateTime get _earliestWatchDate {
    final releaseDateStr = widget.movieData['release_date'] as String?;
    final releaseDate = releaseDateStr != null && releaseDateStr.isNotEmpty ? DateTime.tryParse(releaseDateStr) : null;
    if (releaseDate == null) return DateTime(2000);
    final now = DateTime.now();
    // Guard against not-yet-released titles (upcoming movies): a release
    // date after today would otherwise put firstDate after lastDate.
    return releaseDate.isAfter(now) ? now : releaseDate;
  }

  Future<void> _pickDate() async {
    final firstDate = _earliestWatchDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    final db = ref.read(databaseProvider);
    final movieId = widget.movieData['id'] as int;

    // Combine date and time
    final watchDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Extract director and actors
    final crew = widget.movieData['credits']?['crew'] as List<dynamic>?;
    final directorName = crew?.where((e) => e['job'] == 'Director').firstOrNull?['name'] as String?;
    
    final cast = widget.movieData['credits']?['cast'] as List<dynamic>?;
    final actorsString = cast?.take(5).map((e) => e['name']).join(', ');

    // Extract genres
    final genresData = widget.movieData['genres'] as List<dynamic>?;
    final genresString = genresData?.map((e) => e['name']).join(', ');

    final releaseDateStr = widget.movieData['release_date'] as String? ?? '';
    final releaseYear = DateTime.tryParse(releaseDateStr)?.year;
    final isTv = widget.movieData['media_type'] == 'tv';

    // "Aktif İzliyorum" bookkeeping: how many episodes this record covers,
    // and the new persisted watch-progress state for the show.
    var episodeCountForRecord = _episodeCount;
    var newIsActivelyWatching = false;
    var newLastWatchedEpisode = _lastWatchedEpisode;
    if (isTv) {
      if (_isActivelyWatching) {
        final selected = _totalEpisodes != null ? _selectedEpisode.clamp(1, _totalEpisodes!) : _selectedEpisode;
        episodeCountForRecord = (selected - (_lastWatchedEpisode ?? 0)).clamp(1, selected);
        newLastWatchedEpisode = selected;
        newIsActivelyWatching = _totalEpisodes == null || selected < _totalEpisodes!;
      } else {
        episodeCountForRecord = _totalEpisodes != null ? _episodeCount.clamp(1, _totalEpisodes!) : _episodeCount;
        newLastWatchedEpisode = episodeCountForRecord;
        newIsActivelyWatching = false;
      }
    }

    try {
      if (kIsWeb) {
        final watchListNotifier = ref.read(webWatchRecordsProvider.notifier);
        final currentList = ref.read(webWatchRecordsProvider);

        final existingRecords = currentList.where((r) => r.movieId == movieId && r.isTv == isTv).toList();
        final watchNumber = existingRecords.length + 1;

        final nextId = currentList.isEmpty ? 1 : currentList.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;

        final newRecord = WatchRecord(
          id: nextId,
          movieId: movieId,
          isTv: isTv,
          watchDate: watchDateTime,
          watchPlace: _placeController.text.trim().isEmpty ? null : _placeController.text.trim(),
          watchCompanion: _companionController.text.trim().isEmpty ? null : _companionController.text.trim(),
          rating: _rating,
          mood: _selectedMood,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          watchNumber: watchNumber,
          tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
          createdAt: DateTime.now(),
          episodeCount: episodeCountForRecord,
        );

        // Save movie metadata too
        final moviesNotifier = ref.read(webMoviesProvider.notifier);
        final currentMovies = ref.read(webMoviesProvider);
        final movieKey = (tmdbId: movieId, isTv: isTv);
        final updatedMovies = Map<MovieKey, Movie>.from(currentMovies);
        // Preserve the existing "added at" timestamp if this movie is
        // already in the library, instead of bumping it to "now".
        final existingMovie = currentMovies[movieKey];
        updatedMovies[movieKey] = Movie(
          tmdbId: movieId,
          title: widget.movieData['title'] as String,
          originalTitle: widget.movieData['original_title'] as String?,
          posterPath: widget.movieData['poster_path'] as String?,
          backdropPath: widget.movieData['backdrop_path'] as String?,
          releaseYear: releaseYear,
          runtime: widget.movieData['runtime'] as int?,
          genres: genresString,
          director: directorName,
          actors: actorsString,
          overview: widget.movieData['overview'] as String?,
          isTv: isTv,
          createdAt: existingMovie?.createdAt ?? DateTime.now(),
          totalEpisodes: _totalEpisodes,
        );

        moviesNotifier.state = updatedMovies;
        watchListNotifier.state = [...currentList, newRecord];

        if (isTv) {
          final settingsNotifier = ref.read(webMovieSettingsProvider.notifier);
          final currentSettings = ref.read(webMovieSettingsProvider);
          final existingSetting = currentSettings[movieKey];
          final updatedSettings = Map<MovieKey, UserMovieSetting>.from(currentSettings);
          updatedSettings[movieKey] = UserMovieSetting(
            tmdbId: movieId,
            isTv: isTv,
            isFavorite: existingSetting?.isFavorite ?? false,
            isReWatchList: existingSetting?.isReWatchList ?? false,
            personalRanking: existingSetting?.personalRanking,
            personalNotes: existingSetting?.personalNotes,
            personalTags: existingSetting?.personalTags,
            updatedAt: DateTime.now(),
            isActivelyWatching: newIsActivelyWatching,
            lastWatchedEpisode: newLastWatchedEpisode,
          );
          settingsNotifier.state = updatedSettings;
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.movieData['title']} günlüğünüze başarıyla eklendi!'),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
        return;
      }

      // 1. Insert movie if not exists. createdAt is intentionally absent so
      // re-watching an existing movie doesn't bump its "added at" timestamp.
      await db.into(db.movies).insertOnConflictUpdate(
            MoviesCompanion.insert(
              tmdbId: movieId,
              title: widget.movieData['title'] as String,
              originalTitle: drift.Value(widget.movieData['original_title'] as String?),
              posterPath: drift.Value(widget.movieData['poster_path'] as String?),
              backdropPath: drift.Value(widget.movieData['backdrop_path'] as String?),
              releaseYear: drift.Value(releaseYear),
              runtime: drift.Value(widget.movieData['runtime'] as int?),
              genres: drift.Value(genresString),
              director: drift.Value(directorName),
              actors: drift.Value(actorsString),
              overview: drift.Value(widget.movieData['overview'] as String?),
              isTv: drift.Value(isTv),
              totalEpisodes: drift.Value(_totalEpisodes),
            ),
          );

      // 2. Query existing records to calculate watch number
      final existingRecords = await (db.select(db.watchRecords)
            ..where((t) => t.movieId.equals(movieId) & t.isTv.equals(isTv)))
          .get();
      final watchNumber = existingRecords.length + 1;

      // 3. Insert Watch Record
      await db.into(db.watchRecords).insert(
            WatchRecordsCompanion.insert(
              movieId: movieId,
              isTv: drift.Value(isTv),
              watchDate: watchDateTime,
              watchPlace: drift.Value(_placeController.text.trim().isEmpty ? null : _placeController.text.trim()),
              watchCompanion: drift.Value(_companionController.text.trim().isEmpty ? null : _companionController.text.trim()),
              rating: _rating,
              mood: drift.Value(_selectedMood),
              notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
              watchNumber: watchNumber,
              tags: drift.Value(_tagsController.text.trim().isEmpty ? null : _tagsController.text.trim()),
              createdAt: drift.Value(DateTime.now()),
              episodeCount: drift.Value(episodeCountForRecord),
            ),
          );

      // 4. Update episode-tracking settings for TV shows.
      if (isTv) {
        final existingSetting = await (db.select(db.userMovieSettings)
              ..where((t) => t.tmdbId.equals(movieId) & t.isTv.equals(isTv)))
            .getSingleOrNull();
        await db.into(db.userMovieSettings).insertOnConflictUpdate(
              UserMovieSetting(
                tmdbId: movieId,
                isTv: isTv,
                isFavorite: existingSetting?.isFavorite ?? false,
                isReWatchList: existingSetting?.isReWatchList ?? false,
                personalRanking: existingSetting?.personalRanking,
                personalNotes: existingSetting?.personalNotes,
                personalTags: existingSetting?.personalTags,
                updatedAt: DateTime.now(),
                isActivelyWatching: newIsActivelyWatching,
                lastWatchedEpisode: newLastWatchedEpisode,
              ),
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.movieData['title']} günlüğünüze başarıyla eklendi!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt kaydedilirken hata oluştu: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _seedFromSettingsIfNeeded();

    // Avoid sheet hitting bottom bar / keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Günlüğe İzleme Kaydı Ekle',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),

            // Date and Time Pickers Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      borderRadius: 12,
                      opacity: 0.5,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('dd.MM.yyyy').format(_selectedDate),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      borderRadius: 12,
                      opacity: 0.5,
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating Selector (Slider)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Senin Puanın:',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  '$_rating / 10',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ratingColor,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0, // Thinner track
                activeTrackColor: AppTheme.accentColor,
                inactiveTrackColor: Colors.white.withOpacity(0.08),
                thumbColor: AppTheme.ratingColor,
                overlayColor: AppTheme.ratingColor.withOpacity(0.12),
                valueIndicatorColor: AppTheme.surfaceColor,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0, // Smaller thumb
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16.0,
                ),
                tickMarkShape: SliderTickMarkShape.noTickMark, // Hide tick marks for a cleaner look
                valueIndicatorTextStyle: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              child: Slider(
                value: _rating,
                min: 1.0,
                max: 10.0,
                divisions: 18, // 0.5 steps
                label: _rating.toString(),
                onChanged: (val) {
                  setState(() {
                    _rating = val;
                  });
                },
              ),
            ),

            // Episode Tracking (TV shows only) — TMDb only exposes a single
            // flat episode runtime, so this lets duration stats scale with
            // how many episodes are actually covered instead of applying
            // that one estimate uniformly to every logged watch.
            if (widget.movieData['media_type'] == 'tv') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktif İzliyorum',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Switch(
                    value: _isActivelyWatching,
                    activeThumbColor: AppTheme.accentColor,
                    onChanged: (value) {
                      setState(() {
                        _isActivelyWatching = value;
                        if (value) {
                          final next = (_lastWatchedEpisode ?? 0) + 1;
                          _selectedEpisode = _totalEpisodes != null ? next.clamp(1, _totalEpisodes!) : next;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isActivelyWatching)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bölüm $_selectedEpisode${_totalEpisodes != null ? ' / $_totalEpisodes' : ''}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Row(
                      children: [
                        _buildStepperButton(
                          icon: Icons.remove_rounded,
                          onTap: _selectedEpisode > 1 ? () => setState(() => _selectedEpisode--) : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$_selectedEpisode',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        _buildStepperButton(
                          icon: Icons.add_rounded,
                          onTap: _totalEpisodes == null || _selectedEpisode < _totalEpisodes!
                              ? () => setState(() => _selectedEpisode++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kaç bölüm izledin?',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Row(
                      children: [
                        _buildStepperButton(
                          icon: Icons.remove_rounded,
                          onTap: _episodeCount > 1 ? () => setState(() => _episodeCount--) : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$_episodeCount',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        _buildStepperButton(
                          icon: Icons.add_rounded,
                          onTap: _totalEpisodes == null || _episodeCount < _totalEpisodes!
                              ? () => setState(() => _episodeCount++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
            ],

            // Mood Selector
            Text(
              'İzleme Modu / Ruh Hali:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.accentColor : Colors.grey.shade800,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      mood,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Watch Place Input & Chips
            Text(
              'Nerede İzledin?',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(
                hintText: 'Örn: Kadıköy Sineması, Ev...',
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _placeSuggestions.map((place) {
                return ActionChip(
                  label: Text(place, style: GoogleFonts.inter(fontSize: 11)),
                  backgroundColor: AppTheme.surfaceColor,
                  onPressed: () {
                    setState(() {
                      _placeController.text = place;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Companions Input & Chips
            Text(
              'Kiminle İzledin?',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _companionController,
              decoration: const InputDecoration(
                hintText: 'Örn: Tek başıma, Ahmet, Ailem...',
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _companionSuggestions.map((companion) {
                return ActionChip(
                  label: Text(companion, style: GoogleFonts.inter(fontSize: 11)),
                  backgroundColor: AppTheme.surfaceColor,
                  onPressed: () {
                    setState(() {
                      _companionController.text = companion;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Personal Notes
            Text(
              'Kişisel Notların:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Film hakkında ne düşünüyorsun? Akılda kalıcı sahneler...',
              ),
            ),
            const SizedBox(height: 14),

            // Özel Etiketler (Tags)
            Text(
              'Özel Etiketler (#tag):',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: 'Örn: #nostalji, #sinemada, #yalnız (Virgülle ayırın)...',
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _tagSuggestions.map((tag) {
                return ActionChip(
                  label: Text(tag, style: GoogleFonts.inter(fontSize: 11)),
                  backgroundColor: AppTheme.surfaceColor,
                  onPressed: () {
                    final currentText = _tagsController.text.trim();
                    if (currentText.isEmpty) {
                      _tagsController.text = tag;
                    } else {
                      final tagsList = currentText.split(',').map((t) => t.trim()).toList();
                      if (!tagsList.contains(tag)) {
                        _tagsController.text = '$currentText, $tag';
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Kaydı Günlüğe Ekle',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isEnabled ? AppTheme.accentColor : Colors.grey.shade800, width: 1),
        ),
        child: Icon(icon, size: 16, color: isEnabled ? AppTheme.accentColor : Colors.grey.shade700),
      ),
    );
  }
}
