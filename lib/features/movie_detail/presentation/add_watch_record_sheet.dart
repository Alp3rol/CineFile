import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../auth/controllers/auth_controller.dart';
import 'widgets/episode_tracking_section.dart';
import 'widgets/mood_selector.dart';
import 'widgets/watch_context_fields.dart';
import 'widgets/watch_rating_slider.dart';

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
  bool _isPublic = false;

  // "Aktif İzliyorum" episode tracking (TV only). _totalEpisodes comes from
  // TMDb; _isActivelyWatching/_lastWatchedEpisode are seeded once from the
  // show's persisted UserMovieSettings so this sheet remembers where the
  // user left off across separate watch records.
  int? _totalEpisodes;
  bool _isActivelyWatching = false;
  int? _lastWatchedEpisode;
  int _selectedEpisode = 1;
  bool _seededFromSettings = false;

  // When "Aktif İzliyorum" is off, the default assumption is that the user
  // finished the whole show (that's why they're logging it, not tracking
  // progress). Only switched to false if they explicitly pick "Belirli
  // sayıda bölüm" for a partial-watch entry.
  bool _finishedWholeShow = true;

  late final TextEditingController _episodeCountController = TextEditingController(text: '$_episodeCount');
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
    _episodeCountController.text = '1';
    if (_isActivelyWatching) {
      final next = (_lastWatchedEpisode ?? 0) + 1;
      _selectedEpisode = _totalEpisodes != null ? next.clamp(1, _totalEpisodes!) : next;
    }
  }

  @override
  void dispose() {
    _episodeCountController.dispose();
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

  // Keeps _episodeCount and the text field's controller in sync whether the
  // change came from the stepper buttons or the user typing a number
  // directly — needed for shows with hundreds of episodes where tapping "+"
  // one at a time isn't practical.
  void _setEpisodeCount(int value) {
    final clamped = _totalEpisodes != null ? value.clamp(1, _totalEpisodes!) : (value < 1 ? 1 : value);
    setState(() => _episodeCount = clamped);
    final text = '$clamped';
    if (_episodeCountController.text != text) {
      _episodeCountController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
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
      } else if (_finishedWholeShow && _totalEpisodes != null) {
        final selected = _totalEpisodes!;
        episodeCountForRecord = (selected - (_lastWatchedEpisode ?? 0)).clamp(1, selected);
        newLastWatchedEpisode = selected;
        newIsActivelyWatching = false;
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
        'isPublic': _isPublic,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlüğe İzleme Kaydı Ekle',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Explicit close affordance — the sheet's content can grow
                // tall enough (esp. with the TV episode-tracking section) to
                // fill the whole screen, leaving no backdrop to tap and
                // making drag-to-dismiss fight with the inner scroll view.
                // Without this, there was no way to back out without saving.
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  visualDensity: VisualDensity.compact,
                ),
              ],
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
            WatchRatingSlider(
              rating: _rating,
              onChanged: (val) {
                setState(() {
                  _rating = val;
                });
              },
            ),

            const SizedBox(height: 16),

            // Profile Visibility Toggle — controls ONLY the "Son
            // İzlediklerim" section on the user's own profile screen. This
            // is deliberately unrelated to the Community feed: feed posts
            // are created explicitly via the compose bar's "Film
            // Paylaş"/"Günlüğünü Paylaş" flows (see
            // share_compose_sheet.dart), which snapshot their own data and
            // never read this flag.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public_rounded, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Profilimde Göster',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isPublic,
                        activeThumbColor: AppTheme.accentColor,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Açarsan bu kayıt profilindeki "Son İzlediklerim" bölümünde herkese görünür.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Episode Tracking (TV shows only) — TMDb only exposes a single
            // flat episode runtime, so this lets duration stats scale with
            // how many episodes are actually covered instead of applying
            // that one estimate uniformly to every logged watch.
            if (widget.movieData['media_type'] == 'tv') ...[
              const SizedBox(height: 16),
              EpisodeTrackingSection(
                isActivelyWatching: _isActivelyWatching,
                selectedEpisode: _selectedEpisode,
                totalEpisodes: _totalEpisodes,
                episodeCountController: _episodeCountController,
                finishedWholeShow: _finishedWholeShow,
                onActiveChanged: (value) {
                  setState(() {
                    _isActivelyWatching = value;
                    _episodeCount = 1;
                    _episodeCountController.text = '1';
                    _finishedWholeShow = true;
                    if (value) {
                      final next = (_lastWatchedEpisode ?? 0) + 1;
                      _selectedEpisode = _totalEpisodes != null ? next.clamp(1, _totalEpisodes!) : next;
                    }
                  });
                },
                onFinishedWholeShowChanged: (value) => setState(() => _finishedWholeShow = value),
                onEpisodeCountDecrement: _episodeCount > 1 ? () => _setEpisodeCount(_episodeCount - 1) : null,
                onEpisodeCountIncrement: _totalEpisodes == null || _episodeCount < _totalEpisodes!
                    ? () => _setEpisodeCount(_episodeCount + 1)
                    : null,
                onEpisodeCountTextChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) _setEpisodeCount(parsed);
                },
                onSelectedEpisodeDecrement: _selectedEpisode > 1 ? () => setState(() => _selectedEpisode--) : null,
                onSelectedEpisodeIncrement: _totalEpisodes == null || _selectedEpisode < _totalEpisodes!
                    ? () => setState(() => _selectedEpisode++)
                    : null,
              ),
            ],

            const SizedBox(height: 16),

            // Mood Selector
            MoodSelector(
              moods: _moods,
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 18),

            // Watch Place Input & Chips
            WatchPlaceField(
              controller: _placeController,
              suggestions: _placeSuggestions,
              onSuggestionTap: (place) {
                setState(() {
                  _placeController.text = place;
                });
              },
            ),
            const SizedBox(height: 14),

            // Companions Input & Chips
            WatchCompanionField(
              controller: _companionController,
              suggestions: _companionSuggestions,
              onSuggestionTap: (companion) {
                setState(() {
                  _companionController.text = companion;
                });
              },
            ),
            const SizedBox(height: 14),

            // Personal Notes
            WatchNotesField(controller: _notesController),
            const SizedBox(height: 14),

            // Özel Etiketler (Tags)
            WatchTagsField(controller: _tagsController, suggestions: _tagSuggestions),
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
}
