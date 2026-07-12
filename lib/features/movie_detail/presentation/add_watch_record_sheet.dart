import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../auth/controllers/auth_controller.dart';

class AddWatchRecordSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> movieData;

  const AddWatchRecordSheet({super.key, required this.movieData});

  @override
  ConsumerState<AddWatchRecordSheet> createState() => _AddWatchRecordSheetState();
}

class _AddWatchRecordSheetState extends ConsumerState<AddWatchRecordSheet> {
  late DateTime _selectedDate;
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

    // Default to 1 episode per record regardless of active-tracking state —
    // NOT the show's total episode count. Defaulting to "all episodes" here
    // would apply to every single record added, so logging the same show 4
    // separate times would each count as a full rewatch of the whole series
    // (real bug: duration stats ballooned to 1000+ hours). The user can still
    // raise it manually via the stepper for a genuine "watched it all" entry.
    _episodeCount = 1;
    if (_isActivelyWatching) {
      final next = (_lastWatchedEpisode ?? 0) + 1;
      _selectedEpisode = _totalEpisodes != null ? next.clamp(1, _totalEpisodes!) : next;
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
    final picked = await PremiumDatePicker.show(
      context,
      initialDate: _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) {
      showPremiumToast(context, 'Lütfen önce giriş yapın.', isError: true);
      return;
    }

    final userModel = ref.read(userModelProvider);
    final username = userModel?.username ?? user.email!.split('@')[0];
    final avatarUrl = userModel?.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=$username';

    final movieId = widget.movieData['id'] as int;

    // Combine date and current time
    final now = DateTime.now();
    final watchDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
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

    // Episode count
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
      // 1. Calculate watch number (how many times they watched this movie)
      final existingRecordsQuery = await ref.read(firestoreProvider)
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: movieId)
          .where('isTv', isEqualTo: isTv)
          .get();
      final watchNumber = existingRecordsQuery.docs.length + 1;

      // 2. Generate a new log document
      final logRef = ref.read(firestoreProvider).collection('logs').doc();
      final logData = {
        'id': logRef.id,
        'userId': user.uid,
        'username': username,
        'userAvatarUrl': avatarUrl,
        'movieId': movieId,
        'isTv': isTv,
        'watchDate': Timestamp.fromDate(watchDateTime),
        'watchPlace': _placeController.text.trim().isEmpty ? null : _placeController.text.trim(),
        'watchCompanion': _companionController.text.trim().isEmpty ? null : _companionController.text.trim(),
        'rating': _rating,
        'mood': _selectedMood,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'watchNumber': watchNumber,
        'tags': _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
        'episodeCount': episodeCountForRecord,
        'createdAt': FieldValue.serverTimestamp(),
        'movieTitle': widget.movieData['title'] as String,
        'movieOriginalTitle': widget.movieData['original_title'] as String?,
        'moviePosterPath': widget.movieData['poster_path'] as String?,
        'movieBackdropPath': widget.movieData['backdrop_path'] as String?,
        'movieReleaseYear': releaseYear,
        'movieRuntime': widget.movieData['runtime'] as int?,
        'movieGenres': genresString,
        'movieDirector': directorName,
        'movieActors': actorsString,
        'movieOverview': widget.movieData['overview'] as String?,
        'movieTotalEpisodes': _totalEpisodes,
        'starredBy': <String>[],
        'commentCount': 0,
      };

      await logRef.set(logData);

      // 3. Update movie settings for favorite/rewatch status
      final settingsRef = ref.read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${movieId}_$isTv');

      final settingsDoc = await settingsRef.get();
      final existingSetting = settingsDoc.data();

      await settingsRef.set({
        'movieId': movieId,
        'isTv': isTv,
        'isFavorite': existingSetting?['isFavorite'] ?? false,
        'isReWatchList': existingSetting?['isReWatchList'] ?? false,
        'personalRanking': existingSetting?['personalRanking'],
        'personalNotes': existingSetting?['personalNotes'],
        'personalTags': existingSetting?['personalTags'],
        'updatedAt': FieldValue.serverTimestamp(),
        'isActivelyWatching': newIsActivelyWatching,
        'lastWatchedEpisode': newLastWatchedEpisode,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        showPremiumToast(context, '${widget.movieData['title']} günlüğünüze başarıyla eklendi!');
      }
    } catch (e) {
      if (mounted) {
        showPremiumToast(context, 'Kayıt kaydedilirken hata oluştu: $e', isError: true);
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
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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

            // Date Picker Row
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
                        _episodeCount = 1;
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
