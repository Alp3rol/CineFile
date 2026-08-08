import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../auth/controllers/auth_controller.dart';
import 'widgets/add_watch_record_header.dart';
import 'widgets/episode_tracking_section.dart';
import 'widgets/mood_selector.dart';
import 'widgets/watch_context_fields.dart';
import 'widgets/watch_rating_slider.dart';
import 'widgets/watch_record_episode_math.dart';
import 'widgets/watch_record_visibility_toggle.dart';

String? _nullableText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class AddWatchRecordSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> movieData;

  const AddWatchRecordSheet({super.key, required this.movieData});

  @override
  ConsumerState<AddWatchRecordSheet> createState() =>
      _AddWatchRecordSheetState();
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
  // True until the settings have been re-fetched for this sheet; see initState.
  bool _awaitingFreshSettings = true;

  // When "Aktif İzliyorum" is off, the default assumption is that the user
  // finished the whole show (that's why they're logging it, not tracking
  // progress). Only switched to false if they explicitly pick "Belirli
  // sayıda bölüm" for a partial-watch entry.
  bool _finishedWholeShow = true;

  late final TextEditingController _episodeCountController =
      TextEditingController(text: '$_episodeCount');
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _companionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<String> _moods = [
    '🍿',
    '😊',
    '😢',
    '😱',
    '😴',
    '🔥',
    '❤️',
    '😂',
    '🤯',
    '😭',
    '🥹',
    '🤔',
    '😍',
    '🥱',
    '😤',
    '🤩',
  ];

  // Built per-render rather than as fields: these are localized, and a field
  // initializer has no BuildContext to resolve them from.
  //
  // Whatever the user ends up with is stored as their own free text and shown
  // back verbatim — these chips only save typing. A user who switches language
  // mid-history will therefore have entries in both, which is the same as if
  // they had typed them; the one place it matters semantically is the Journal's
  // "cinema" filter, which matches the word in either language.
  List<String> _placeSuggestions(AppLocalizations l10n) => [
    l10n.placeHome,
    l10n.placeCinema,
    l10n.placeFriendsHouse,
    l10n.placeTravelling,
    l10n.placeHotel,
    l10n.placePlane,
    l10n.placeGarden,
    l10n.placeCamping,
    l10n.placeWork,
  ];
  List<String> _companionSuggestions(AppLocalizations l10n) => [
    l10n.companionAlone,
    l10n.companionFriends,
    l10n.companionFamily,
    l10n.companionPartner,
    l10n.companionSpouse,
    l10n.companionSibling,
    l10n.companionKids,
    l10n.companionColleagues,
  ];
  List<String> _tagSuggestions(AppLocalizations l10n) => [
    l10n.tagNostalgia,
    l10n.tagAtTheCinema,
    l10n.tagAlone,
    l10n.tagAction,
    l10n.tagRomance,
    l10n.tagThriller,
    l10n.tagComedy,
    l10n.tagDrama,
    l10n.tagSciFi,
    l10n.tagHorror,
    l10n.tagClassic,
    l10n.tagNewDiscovery,
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _totalEpisodes = (widget.movieData['number_of_episodes'] as num?)?.toInt();

    // This sheet is reopened after every saved record, and
    // _seedFromSettingsIfNeeded below latches onto the first settings value it
    // sees. Nothing listens to those settings while the sheet is closed, so
    // that first value can predate the record just saved (see
    // refreshMovieSettings) — ask for a fresh one, and don't seed until it
    // lands. Deferred to a post-frame callback because invalidating a provider
    // from initState happens mid-build, which the framework rejects.
    if (widget.movieData['media_type'] == 'tv') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        refreshMovieSettings(ref, (
          tmdbId: (widget.movieData['id'] as num).toInt(),
          isTv: true,
        ));
        setState(() => _awaitingFreshSettings = false);
      });
    } else {
      _awaitingFreshSettings = false;
    }
  }

  // Seeds _isActivelyWatching/_lastWatchedEpisode from the show's persisted
  // UserMovieSettings exactly once, the first time that data is actually
  // available. Done in build() (not initState) because the native settings
  // provider is a Stream that may not have emitted yet on first mount —
  // reading ref.read(...).value there could silently see null even when a
  // row already exists in the database.
  void _seedFromSettingsIfNeeded() {
    if (_seededFromSettings ||
        _awaitingFreshSettings ||
        widget.movieData['media_type'] != 'tv') {
      return;
    }

    final tmdbId = (widget.movieData['id'] as num).toInt();
    final asyncSettings = ref.watch(
      movieSettingsSnapshotProvider((tmdbId: tmdbId, isTv: true)),
    );
    // Not just `hasValue`: after the refresh in initState the provider reports
    // AsyncData(isLoading: true) carrying the value it had *before* the
    // refresh, and seeding from that is exactly what the refresh is meant to
    // avoid. Wait for a settled value — try again next build until then.
    if (asyncSettings.isLoading || !asyncSettings.hasValue) return;
    final existing = asyncSettings.value;

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
      _selectedEpisode = _totalEpisodes != null
          ? next.clamp(1, _totalEpisodes!)
          : next;
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
    final releaseDateStr =
        (widget.movieData['release_date'] ?? widget.movieData['first_air_date'])
            as String?;
    final releaseDate = releaseDateStr != null && releaseDateStr.isNotEmpty
        ? DateTime.tryParse(releaseDateStr)
        : null;
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
      initialDate: _selectedDate.isBefore(firstDate)
          ? firstDate
          : _selectedDate,
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
    final clamped = _totalEpisodes != null
        ? value.clamp(1, _totalEpisodes!)
        : (value < 1 ? 1 : value);
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
    // Resolved up front: everything below runs after awaits, where reading
    // from context is no longer safe.
    final l10n = AppLocalizations.of(context);
    final user = ref.currentUser;
    if (user == null) {
      showPremiumToast(
        context,
        AppLocalizations.of(context).addRecordSignInRequired,
        isError: true,
      );
      return;
    }

    final movieId = (widget.movieData['id'] as num).toInt();

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
    final directorName =
        crew
                ?.where((e) => (e is Map) && e['job'] == 'Director')
                .firstOrNull?['name']
            as String?;

    final cast = widget.movieData['credits']?['cast'] as List<dynamic>?;
    final actorsString = cast
        ?.take(5)
        .map((e) => (e is Map) ? (e['name'] ?? '') : '')
        .where((s) => s.toString().isNotEmpty)
        .join(', ');

    // Extract genres
    final genresData = widget.movieData['genres'] as List<dynamic>?;
    final genresString = genresData
        ?.map((e) => (e is Map) ? (e['name'] ?? '') : '')
        .where((s) => s.toString().isNotEmpty)
        .join(', ');

    final releaseDateStr =
        (widget.movieData['release_date'] ??
                widget.movieData['first_air_date'] ??
                '')
            .toString();
    final releaseYear = DateTime.tryParse(releaseDateStr)?.year;
    final isTv = widget.movieData['media_type'] == 'tv';

    // Episode count
    final episodeFields = computeWatchRecordEpisodeFields(
      isTv: isTv,
      isActivelyWatching: _isActivelyWatching,
      finishedWholeShow: _finishedWholeShow,
      episodeCount: _episodeCount,
      selectedEpisode: _selectedEpisode,
      totalEpisodes: _totalEpisodes,
      lastWatchedEpisode: _lastWatchedEpisode,
    );
    final episodeCountForRecord = episodeFields.episodeCount;
    final newIsActivelyWatching = episodeFields.isActivelyWatching;
    final newLastWatchedEpisode = episodeFields.lastWatchedEpisode;

    try {
      final movieTitle =
          (widget.movieData['title'] ??
                  widget.movieData['name'] ??
                  l10n.titleUnknown)
              .toString();
      final watchNumber = await ref
          .read(watchRecordServiceProvider)
          .create(
            WatchRecordDraft(
              movieId: movieId,
              isTv: isTv,
              watchDate: watchDateTime,
              watchPlace: _nullableText(_placeController.text),
              watchCompanion: _nullableText(_companionController.text),
              rating: _rating,
              mood: _selectedMood,
              notes: _nullableText(_notesController.text),
              tags: _nullableText(_tagsController.text),
              episodeCount: episodeCountForRecord,
              movieTitle: movieTitle,
              movieOriginalTitle:
                  (widget.movieData['original_title'] ??
                          widget.movieData['original_name'])
                      as String?,
              moviePosterPath: widget.movieData['poster_path'] as String?,
              movieBackdropPath: widget.movieData['backdrop_path'] as String?,
              movieReleaseYear: releaseYear,
              movieRuntime: (widget.movieData['runtime'] as num?)?.toInt(),
              movieGenres: genresString,
              movieDirector: directorName,
              movieActors: actorsString,
              movieOverview: widget.movieData['overview'] as String?,
              movieTotalEpisodes: _totalEpisodes,
              isPublic: _isPublic,
              isActivelyWatching: newIsActivelyWatching,
              lastWatchedEpisode: newLastWatchedEpisode,
            ),
          );
      debugPrint('Saved watch record #$watchNumber for "$movieTitle"');

      if (mounted) {
        Navigator.pop(context, true);
        showPremiumToast(
          context,
          AppLocalizations.of(context).addRecordSuccess(
            widget.movieData['title'] ??
                widget.movieData['name'] ??
                AppLocalizations.of(context).titleUnknown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Saving the watch record failed: $e');
        showPremiumToast(
          context,
          AppLocalizations.of(context).addRecordSaveFailed,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _seedFromSettingsIfNeeded();

    // Avoid sheet hitting bottom bar / keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // Cap the sheet's height so it never eats the whole screen — the fields
    // above (esp. the TV episode-tracking section) scroll inside that cap,
    // while the submit button below stays outside the scroll view and is
    // therefore always visible, never requiring a scroll to reach it.
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.topXl,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddWatchRecordHeader(onClose: () => Navigator.pop(context)),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Picker Row
                    Row(
                      children: [
                        Expanded(
                          child: AppPressable(
                            onTap: _pickDate,
                            borderRadius: AppRadius.md,
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                                horizontal: AppSpacing.lg,
                              ),
                              borderRadius: AppRadius.md,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.accent,
                                    size: AppSize.iconMd,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(_selectedDate),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
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

                    WatchRecordVisibilityToggle(
                      isPublic: _isPublic,
                      onChanged: (value) => setState(() => _isPublic = value),
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
                              _selectedEpisode = _totalEpisodes != null
                                  ? next.clamp(1, _totalEpisodes!)
                                  : next;
                            }
                          });
                        },
                        onFinishedWholeShowChanged: (value) =>
                            setState(() => _finishedWholeShow = value),
                        onEpisodeCountDecrement: _episodeCount > 1
                            ? () => _setEpisodeCount(_episodeCount - 1)
                            : null,
                        onEpisodeCountIncrement:
                            _totalEpisodes == null ||
                                _episodeCount < _totalEpisodes!
                            ? () => _setEpisodeCount(_episodeCount + 1)
                            : null,
                        onEpisodeCountTextChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) _setEpisodeCount(parsed);
                        },
                        onSelectedEpisodeDecrement: _selectedEpisode > 1
                            ? () => setState(() => _selectedEpisode--)
                            : null,
                        onSelectedEpisodeIncrement:
                            _totalEpisodes == null ||
                                _selectedEpisode < _totalEpisodes!
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
                      suggestions: _placeSuggestions(
                        AppLocalizations.of(context),
                      ),
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
                      suggestions: _companionSuggestions(
                        AppLocalizations.of(context),
                      ),
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
                    WatchTagsField(
                      controller: _tagsController,
                      suggestions: _tagSuggestions(
                        AppLocalizations.of(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Submit Button — deliberately outside the Flexible/scroll area
          // above so it's always visible without scrolling, regardless of
          // how tall the form above gets (see maxSheetHeight comment).
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: AppButton(
              label: AppLocalizations.of(context).addRecordSubmit,
              isFullWidth: true,
              onPressed: _saveRecord,
            ),
          ),
        ],
      ),
    );
  }
}
