import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/movie_repository.dart';
import '../../../core/l10n/genre_names.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../movie_detail/presentation/add_watch_record_sheet.dart';
import '../../movie_detail/presentation/movie_detail_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../movie_detail/presentation/widgets/movie_detail_watch_providers_section.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/swipe_preference_signal.dart';

enum _SwipeChoice { interested, notInterested }

class _SwipeAction {
  const _SwipeAction(this.item, this.choice);

  final Map<String, dynamic> item;
  final _SwipeChoice choice;
}

class SwipeDiscoveryScreen extends ConsumerStatefulWidget {
  const SwipeDiscoveryScreen({super.key, required this.items, this.onRefresh});

  final List<Map<String, dynamic>> items;
  final Future<List<Map<String, dynamic>>> Function()? onRefresh;

  @override
  ConsumerState<SwipeDiscoveryScreen> createState() =>
      _SwipeDiscoveryScreenState();
}

class _SwipeDiscoveryScreenState extends ConsumerState<SwipeDiscoveryScreen> {
  static const _gestureGuideKey = 'swipe_gesture_guide_seen_v1';

  late List<Map<String, dynamic>> _remaining;
  final List<_SwipeAction> _history = [];
  bool _isWriting = false;
  bool _showGestureGuide = false;
  int _sessionWatched = 0;

  @override
  void initState() {
    super.initState();
    _remaining = List<Map<String, dynamic>>.from(widget.items);
    unawaited(_loadGestureGuide());
  }

  Future<void> _loadGestureGuide() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted || preferences.getBool(_gestureGuideKey) == true) return;
    setState(() => _showGestureGuide = true);
  }

  void _dismissGestureGuide() {
    if (_showGestureGuide) setState(() => _showGestureGuide = false);
    unawaited(
      SharedPreferences.getInstance().then(
        (preferences) => preferences.setBool(_gestureGuideKey, true),
      ),
    );
  }

  MovieKey _keyFor(Map<String, dynamic> item) =>
      (tmdbId: (item['id'] as num).toInt(), isTv: item['media_type'] == 'tv');

  List<Map<String, dynamic>> _visibleItems(WidgetRef ref) {
    final settings = ref.watch(allMovieSettingsProvider).value ?? const {};
    final decisionKeys =
        (ref.watch(swipePreferenceSignalsProvider).value ?? const [])
            .map((signal) => signal.key)
            .whereType<MovieKey>()
            .toSet();
    final watched = (ref.watch(allWatchRecordsProvider).value ?? const [])
        .map((record) => (tmdbId: record.movie.tmdbId, isTv: record.movie.isTv))
        .toSet();

    return _remaining.where((item) {
      final key = _keyFor(item);
      return !watched.contains(key) &&
          !(settings[key]?.isReWatchList ?? false) &&
          !decisionKeys.contains(key);
    }).toList();
  }

  Future<void> _choose(Map<String, dynamic> item, _SwipeChoice choice) async {
    if (_isWriting) return;
    _dismissGestureGuide();
    setState(() {
      _isWriting = true;
      _remaining.remove(item);
      _history.add(_SwipeAction(item, choice));
    });

    try {
      await _writeChoice(item, choice);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: choice == _SwipeChoice.interested
              ? Text(l10n.swipeAddedToWatchlist)
              : Row(
                  children: [
                    Expanded(child: Text(l10n.swipePassed)),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        _askSkipReason(item);
                      },
                      child: Text(l10n.swipeWhy),
                    ),
                  ],
                ),
          action: SnackBarAction(label: l10n.swipeUndo, onPressed: _undo),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _history.removeLast();
        _remaining.insert(0, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).swipeSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _isWriting = false);
    }
  }

  Future<void> _writeChoice(
    Map<String, dynamic> item,
    _SwipeChoice choice,
  ) async {
    final user = ref.currentUser;
    if (user == null) throw StateError('Authentication required');
    final key = _keyFor(item);
    final releaseDate =
        (key.isTv ? item['first_air_date'] : item['release_date']) as String? ??
        '';
    final data = <String, dynamic>{
      'movieId': key.tmdbId,
      'isTv': key.isTv,
      'swipeDecision': choice == _SwipeChoice.interested
          ? 'interested'
          : 'notInterested',
      'swipeDecidedAt': FieldValue.serverTimestamp(),
      'swipeGenreIds': (item['genre_ids'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((id) => id.toInt())
          .toList(growable: false),
      'swipeSkipReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (choice == _SwipeChoice.interested) {
      data['isReWatchList'] = true;
      data['releaseDate'] = releaseDate;
    }

    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${key.tmdbId}_${key.isTv}')
        .set(data, SetOptions(merge: true));

    unawaited(
      _publishPublicTasteIfEnabled(
        removeKey: key,
        replacement: SwipePreferenceSignal(
          isInterested: choice == _SwipeChoice.interested,
          genreIds: (item['genre_ids'] as List<dynamic>? ?? const [])
              .whereType<num>()
              .map((id) => id.toInt())
              .toList(growable: false),
          key: key,
        ),
      ),
    );

    if (choice == _SwipeChoice.interested) {
      // The Firestore write above is the user's actual intent. Metadata is a
      // best-effort offline cache and must not turn a successful watchlist
      // addition into an apparent failure.
      try {
        await ref
            .read(movieRepositoryProvider)
            .cacheMovieMetadata(
              tmdbId: key.tmdbId,
              isTv: key.isTv,
              movieData: item,
            );
      } catch (error) {
        debugPrint('Writing swipe-discovery metadata cache failed: $error');
      }

      await _scheduleReleaseReminderIfNeeded(
        item: item,
        key: key,
        releaseDate: releaseDate,
      );
    }
  }

  Future<void> _askSkipReason(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF171A22),
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.swipeSkipReasonTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.swipeSkipReasonHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _SkipReasonTile(
                icon: Icons.category_outlined,
                label: l10n.swipeSkipReasonGenre,
                onTap: () => Navigator.pop(sheetContext, 'dislikeGenre'),
              ),
              _SkipReasonTile(
                icon: Icons.sentiment_dissatisfied_outlined,
                label: l10n.swipeSkipReasonTitleSpecific,
                onTap: () => Navigator.pop(sheetContext, 'notForMe'),
              ),
              _SkipReasonTile(
                icon: Icons.schedule_rounded,
                label: l10n.swipeSkipReasonNotNow,
                onTap: () => Navigator.pop(sheetContext, 'notNow'),
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null || !mounted) return;

    final user = ref.currentUser;
    if (user == null) return;
    final key = _keyFor(item);
    try {
      await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${key.tmdbId}_${key.isTv}')
          .set({
            'swipeSkipReason': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      unawaited(
        _publishPublicTasteIfEnabled(
          removeKey: key,
          replacement: SwipePreferenceSignal(
            isInterested: false,
            genreIds: (item['genre_ids'] as List<dynamic>? ?? const [])
                .whereType<num>()
                .map((id) => id.toInt())
                .toList(growable: false),
            key: key,
            skipReason: reason,
          ),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.swipeSkipReasonSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.swipeSaveFailed)));
    }
  }

  Future<void> _publishPublicTasteIfEnabled({
    required MovieKey removeKey,
    SwipePreferenceSignal? replacement,
  }) async {
    final user = ref.currentUser;
    if (user == null) return;
    try {
      final userReference = ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid);
      final userDocument = await userReference.get();
      if (userDocument.data()?['shareSwipeTasteForMatching'] != true) return;

      final signals = [
        for (final signal
            in ref.read(swipePreferenceSignalsProvider).value ??
                const <SwipePreferenceSignal>[])
          if (signal.key != removeKey) signal,
        ?replacement,
      ];
      final profile = buildSwipeTasteProfile(signals);
      await userReference.set({
        'publicSwipeTasteGenreIds': profile.genreIds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      // Public matching is optional. Its sync must never turn a successful
      // private swipe decision into an apparent failure.
      debugPrint('Publishing swipe taste profile failed: $error');
    }
  }

  Future<void> _scheduleReleaseReminderIfNeeded({
    required Map<String, dynamic> item,
    required MovieKey key,
    required String releaseDate,
  }) async {
    if (!ref.read(releaseRemindersEnabledProvider) || releaseDate.isEmpty) {
      return;
    }
    final parsedDate = DateTime.tryParse(releaseDate);
    if (parsedDate == null || !parsedDate.isAfter(DateTime.now())) return;

    final title =
        (key.isTv
                ? (item['name'] ?? item['original_name'] ?? item['title'])
                : (item['title'] ?? item['original_title'] ?? item['name']))
            ?.toString();
    try {
      await ref
          .read(notificationServiceProvider)
          .scheduleReleaseReminder(
            id: key.tmdbId,
            title: title ?? AppLocalizations.of(context).titleUnknown,
            releaseDate: parsedDate,
            isTv: key.isTv,
          );
    } catch (error) {
      // The watchlist write has already succeeded. A platform notification
      // failure must not roll that intent back or return the card to the deck.
      debugPrint('Scheduling swipe-discovery reminder failed: $error');
    }
  }

  Future<void> _undo() async {
    if (_isWriting || _history.isEmpty) return;
    final action = _history.removeLast();
    final user = ref.currentUser;
    if (user == null) return;
    final key = _keyFor(action.item);

    setState(() {
      _isWriting = true;
      _remaining.insert(0, action.item);
    });
    try {
      final changes = <String, dynamic>{
        'swipeDecision': FieldValue.delete(),
        'swipeDecidedAt': FieldValue.delete(),
        'swipeGenreIds': FieldValue.delete(),
        'swipeSkipReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (action.choice == _SwipeChoice.interested) {
        changes['isReWatchList'] = false;
      }
      await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${key.tmdbId}_${key.isTv}')
          .set(changes, SetOptions(merge: true));
      await _publishPublicTasteIfEnabled(removeKey: key);
      if (action.choice == _SwipeChoice.interested &&
          ref.read(releaseRemindersEnabledProvider)) {
        try {
          await ref
              .read(notificationServiceProvider)
              .cancelReleaseReminder(key.tmdbId, key.isTv);
        } catch (error) {
          debugPrint('Cancelling swipe-discovery reminder failed: $error');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _remaining.remove(action.item);
          _history.add(action);
        });
      }
    } finally {
      if (mounted) setState(() => _isWriting = false);
    }
  }

  Future<void> _markWatched(Map<String, dynamic> item) async {
    if (_isWriting) return;
    _dismissGestureGuide();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddWatchRecordSheet(movieData: item),
    );
    if (saved == true && mounted) {
      setState(() {
        _remaining.remove(item);
        _sessionWatched += 1;
      });
    }
  }

  void _showQuickLook(Map<String, dynamic> item) {
    final isTv = item['media_type'] == 'tv';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuickLookSheet(item: item, isTv: isTv),
    );
  }

  Future<void> _refreshDeck() async {
    final refresh = widget.onRefresh;
    if (refresh == null || _isWriting) return;
    setState(() => _isWriting = true);
    try {
      final items = await refresh();
      if (!mounted) return;
      setState(() {
        _remaining = List<Map<String, dynamic>>.from(items);
        _history.clear();
        _sessionWatched = 0;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).swipeRefreshFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isWriting = false);
    }
  }

  Future<void> _confirmResetPreferences() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.swipeResetTitle),
        content: Text(l10n.swipeResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.swipeResetAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _resetPreferences();
  }

  Future<void> _resetPreferences() async {
    final user = ref.currentUser;
    if (user == null || _isWriting) return;
    setState(() => _isWriting = true);
    try {
      final firestore = ref.read(firestoreProvider);
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .where('swipeDecision', isNull: false)
          .get();

      // Firestore batches accept at most 500 writes. Leave headroom so this
      // remains safe even for people who have used the deck for a long time.
      for (var start = 0; start < snapshot.docs.length; start += 400) {
        final end = start + 400 < snapshot.docs.length
            ? start + 400
            : snapshot.docs.length;
        final batch = firestore.batch();
        for (final document in snapshot.docs.sublist(start, end)) {
          batch.set(document.reference, {
            'swipeDecision': FieldValue.delete(),
            'swipeDecidedAt': FieldValue.delete(),
            'swipeGenreIds': FieldValue.delete(),
            'swipeSkipReason': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }
      final userDocument = await firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDocument.data()?['shareSwipeTasteForMatching'] == true) {
        await userDocument.reference.set({
          'publicSwipeTasteGenreIds': <int>[],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      setState(() {
        _history.clear();
        _remaining = List<Map<String, dynamic>>.from(widget.items);
        _sessionWatched = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).swipeResetDone)),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).swipeSaveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isWriting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _visibleItems(ref);
    final sessionAdded = _history
        .where((action) => action.choice == _SwipeChoice.interested)
        .length;
    final sessionPassed = _history
        .where((action) => action.choice == _SwipeChoice.notInterested)
        .length;
    final sessionGenreIds = rankedSwipeGenreIds(
      _history.map(
        (action) => SwipePreferenceSignal(
          isInterested: action.choice == _SwipeChoice.interested,
          genreIds: (action.item['genre_ids'] as List<dynamic>? ?? const [])
              .whereType<num>()
              .map((id) => id.toInt())
              .toList(growable: false),
        ),
      ),
    ).take(2).toList(growable: false);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.swipeDiscoverTitle),
        actions: [
          IconButton(
            tooltip: l10n.swipeUndo,
            onPressed: _history.isEmpty || _isWriting ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.swipeMoreOptions,
            onSelected: (value) {
              if (value == 'reset') _confirmResetPreferences();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt_rounded),
                    const SizedBox(width: 10),
                    Text(l10n.swipeResetAction),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            if (items.isNotEmpty && !_isWriting) {
              _choose(items.first, _SwipeChoice.notInterested);
            }
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            if (items.isNotEmpty && !_isWriting) {
              _choose(items.first, _SwipeChoice.interested);
            }
          },
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            if (items.isNotEmpty && !_isWriting) {
              _markWatched(items.first);
            }
          },
          const SingleActivator(LogicalKeyboardKey.space): () {
            if (items.isNotEmpty && !_isWriting) {
              _showQuickLook(items.first);
            }
          },
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
            if (_history.isNotEmpty && !_isWriting) _undo();
          },
        },
        child: Focus(
          autofocus: true,
          child: SafeArea(
            child: items.isEmpty
                ? _EmptyDeck(
                    onUndo: _history.isEmpty ? null : _undo,
                    onRefresh: widget.onRefresh == null ? null : _refreshDeck,
                    isLoading: _isWriting,
                    addedCount: sessionAdded,
                    passedCount: sessionPassed,
                    watchedCount: _sessionWatched,
                    preferredGenreIds: sessionGenreIds,
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppTheme.accentColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.swipeRemaining(items.length),
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: _showGestureGuide
                            ? _GestureGuide(
                                text: l10n.swipeDiscoverHint,
                                closeLabel: l10n.commonClose,
                                onClose: _dismissGestureGuide,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (items.length > 1)
                                Positioned.fill(
                                  top: 14,
                                  left: 10,
                                  right: 10,
                                  child: Transform.scale(
                                    scale: 0.96,
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: 0.7,
                                        child: _PremiumDiscoveryCard(
                                          item: items[1],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned.fill(
                                bottom: items.length > 1 ? 12 : 0,
                                child: _SwipeableDiscoveryCard(
                                  key: ValueKey('${_keyFor(items.first)}'),
                                  enabled: !_isWriting,
                                  interestedLabel: l10n.swipeInterested,
                                  notInterestedLabel: l10n.swipeNotInterested,
                                  onInteractionStarted: _dismissGestureGuide,
                                  onChoice: (choice) =>
                                      _choose(items.first, choice),
                                  child: _PremiumDiscoveryCard(
                                    item: items.first,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(26, 12, 26, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ActionButton(
                              tooltip: l10n.swipeNotInterested,
                              label: l10n.swipeNotInterested,
                              icon: Icons.close_rounded,
                              color: const Color(0xFFE35D6A),
                              diameter: 52,
                              onPressed: _isWriting
                                  ? null
                                  : () => _choose(
                                      items.first,
                                      _SwipeChoice.notInterested,
                                    ),
                            ),
                            _ActionButton(
                              tooltip: l10n.swipeWatched,
                              label: l10n.swipeWatched,
                              icon: Icons.visibility_rounded,
                              color: AppTheme.accentColor,
                              diameter: 58,
                              onPressed: _isWriting
                                  ? null
                                  : () => _markWatched(items.first),
                            ),
                            _ActionButton(
                              tooltip: l10n.swipeInterested,
                              label: l10n.swipeInterested,
                              icon: Icons.bookmark_add_rounded,
                              color: const Color(0xFF39C987),
                              diameter: 64,
                              onPressed: _isWriting
                                  ? null
                                  : () => _choose(
                                      items.first,
                                      _SwipeChoice.interested,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title =
        (item['title'] ??
                item['name'] ??
                AppLocalizations.of(context).titleUnknown)
            as String;
    final date =
        (item['release_date'] ?? item['first_air_date'] ?? '') as String;
    final year = date.split('-').first;
    final overview = item['overview'] as String? ?? '';
    final reason = item['recommendation_reason'] as String?;
    final rating = (item['vote_average'] as num?)?.toDouble();
    final isTv = item['media_type'] == 'tv';
    final poster = item['poster_path'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(
            tmdbId: (item['id'] as num).toInt(),
            isTv: isTv,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: poster.isEmpty
                  ? ''
                  : '${ApiConstants.imagePathOriginal}$poster',
              seed: title,
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE612141C)],
                  stops: [0.38, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (year.isNotEmpty) _InfoPill(year),
                      _InfoPill(
                        isTv
                            ? AppLocalizations.of(context).discoverFilterShows
                            : AppLocalizations.of(context).discoverFilterMovies,
                      ),
                      if (rating != null && rating > 0)
                        _InfoPill('★ ${rating.toStringAsFixed(1)}'),
                    ],
                  ),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      text,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
    ),
  );
}

class _PremiumDiscoveryCard extends StatelessWidget {
  const _PremiumDiscoveryCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = (item['title'] ?? item['name'] ?? l10n.titleUnknown)
        .toString();
    final date = (item['release_date'] ?? item['first_air_date'] ?? '')
        .toString();
    final year = date.length >= 4 ? date.substring(0, 4) : '';
    final overview = (item['overview'] ?? '').toString();
    final reason = item['recommendation_reason']?.toString();
    final rating = (item['vote_average'] as num?)?.toDouble();
    final isTv = item['media_type'] == 'tv';
    final poster = (item['poster_path'] ?? '').toString();
    final genreIds = (item['genre_ids'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((id) => id.toInt())
        .take(3)
        .toList(growable: false);
    final compactHeight = MediaQuery.sizeOf(context).height < 650;

    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _QuickLookSheet(item: item, isTv: isTv),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                imageUrl: poster.isEmpty
                    ? ''
                    : '${ApiConstants.imagePathOriginal}$poster',
                seed: title,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33000000),
                      Colors.transparent,
                      Color(0x2406080E),
                      Color(0xE6090B11),
                      Color(0xFF090B11),
                    ],
                    stops: [0, 0.38, 0.54, 0.76, 1],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x5C000000), Colors.transparent],
                    stops: [0, 0.72],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: _RatingBadge(rating: rating),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: compactHeight ? 12 : 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _InfoPill(
                          isTv
                              ? l10n.discoverFilterShows
                              : l10n.discoverFilterMovies,
                        ),
                        if (year.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _InfoPill(year),
                        ],
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: compactHeight ? 22 : 25,
                        height: 1.02,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: genreIds
                          .map((id) => _InfoPill(genreName(l10n, id)))
                          .toList(growable: false),
                    ),
                    if (reason != null && reason.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppTheme.accentColor,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppTheme.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!compactHeight && overview.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white.withValues(alpha: 0.42),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double? rating;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xD90B0D12),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFFCF4A), size: 16),
        const SizedBox(width: 4),
        Text(
          rating != null && rating! > 0 ? rating!.toStringAsFixed(1) : '—',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _QuickLookSheet extends ConsumerWidget {
  const _QuickLookSheet({required this.item, required this.isTv});

  final Map<String, dynamic> item;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tmdbId = (item['id'] as num).toInt();
    final detailAsync = ref.watch(
      movieDetailProvider((tmdbId: tmdbId, isTv: isTv)),
    );
    final details = detailAsync.value ?? item;
    final title = (details['title'] ?? details['name'] ?? l10n.titleUnknown)
        .toString();
    final overview = (details['overview'] ?? item['overview'] ?? '').toString();
    final imagePath =
        (details['backdrop_path'] ??
                details['poster_path'] ??
                item['backdrop_path'] ??
                item['poster_path'] ??
                '')
            .toString();
    final genreIds =
        (details['genre_ids'] as List<dynamic>? ??
                item['genre_ids'] as List<dynamic>? ??
                const [])
            .whereType<num>()
            .map((id) => id.toInt())
            .take(4);
    final runtime = (details['runtime'] as num?)?.toInt();
    final seasons = (details['number_of_seasons'] as num?)?.toInt();
    final crew = details['credits']?['crew'] as List<dynamic>? ?? const [];
    final director = crew
        .whereType<Map<String, dynamic>>()
        .where((person) => person['job'] == 'Director')
        .map((person) => person['name']?.toString())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .firstOrNull;
    final cast = (details['credits']?['cast'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((person) => person['name']?.toString())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .take(3)
        .join(', ');

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF11131A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 2,
              child: AppNetworkImage(
                imageUrl: imagePath.isEmpty
                    ? ''
                    : '${ApiConstants.imagePathW780}$imagePath',
                seed: title,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (runtime != null && runtime > 0)
                        _InfoPill(l10n.durationMinutes(runtime)),
                      if (seasons != null && seasons > 0)
                        _InfoPill(l10n.swipeSeasonCount(seasons)),
                      ...genreIds.map((id) => _InfoPill(genreName(l10n, id))),
                    ],
                  ),
                  if (detailAsync.isLoading) ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                  if (director != null) ...[
                    const SizedBox(height: 18),
                    _DetailLine(label: l10n.detailDirector, value: director),
                  ],
                  if (cast.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _DetailLine(label: l10n.detailCast, value: cast),
                  ],
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      overview,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (detailAsync.hasError) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(
                        movieDetailProvider((tmdbId: tmdbId, isTv: isTv)),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonRetry),
                    ),
                  ],
                  const SizedBox(height: 22),
                  MovieDetailWatchProvidersSection(tmdbId: tmdbId, isTv: isTv),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(
                              tmdbId: (item['id'] as num).toInt(),
                              isTv: isTv,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.swipeViewDetails),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 82,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

class _GestureGuide extends StatelessWidget {
  const _GestureGuide({
    required this.text,
    required this.closeLabel,
    required this.onClose,
  });

  final String text;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.swipe_rounded,
            color: AppTheme.accentColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.76),
                fontSize: 10.5,
                height: 1.25,
              ),
            ),
          ),
          IconButton(
            tooltip: closeLabel,
            visualDensity: VisualDensity.compact,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
        ],
      ),
    ),
  );
}

class _SwipeableDiscoveryCard extends StatefulWidget {
  const _SwipeableDiscoveryCard({
    super.key,
    required this.child,
    required this.interestedLabel,
    required this.notInterestedLabel,
    required this.onInteractionStarted,
    required this.onChoice,
    required this.enabled,
  });

  final Widget child;
  final String interestedLabel;
  final String notInterestedLabel;
  final VoidCallback onInteractionStarted;
  final ValueChanged<_SwipeChoice> onChoice;
  final bool enabled;

  @override
  State<_SwipeableDiscoveryCard> createState() =>
      _SwipeableDiscoveryCardState();
}

class _SwipeableDiscoveryCardState extends State<_SwipeableDiscoveryCard> {
  double _dragX = 0;
  bool _isDragging = false;
  bool _isExiting = false;
  bool _thresholdFeedbackSent = false;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _isExiting) return;
    if (!_isDragging) widget.onInteractionStarted();
    final width = context.size?.width ?? 320;
    final nextDragX = _dragX + details.delta.dx;
    final reachedThreshold = nextDragX.abs() >= width * 0.22;
    if (reachedThreshold && !_thresholdFeedbackSent) {
      _thresholdFeedbackSent = true;
      unawaited(HapticFeedback.selectionClick());
    } else if (!reachedThreshold) {
      _thresholdFeedbackSent = false;
    }
    setState(() {
      _isDragging = true;
      _dragX = nextDragX;
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (!widget.enabled || _isExiting) return;
    final width = context.size?.width ?? 320;
    final velocity = details.primaryVelocity ?? 0;
    final commits = _dragX.abs() >= width * 0.22 || velocity.abs() >= 900;
    if (!commits) {
      setState(() {
        _isDragging = false;
        _dragX = 0;
        _thresholdFeedbackSent = false;
      });
      return;
    }

    final direction = _dragX == 0 ? velocity.sign : _dragX.sign;
    final choice = direction > 0
        ? _SwipeChoice.interested
        : _SwipeChoice.notInterested;
    setState(() {
      _isDragging = false;
      _isExiting = true;
      _dragX = direction * (width + 140);
    });
    unawaited(HapticFeedback.mediumImpact());
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (mounted) widget.onChoice(choice);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 320;
      final progress = (_dragX / width).clamp(-1.0, 1.0);
      final isInterested = progress > 0;
      final showDecision = progress.abs() > 0.06;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: widget.enabled ? _onDragUpdate : null,
        onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
        child: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.translationValues(_dragX, 0, 0)
            ..rotateZ(progress * 0.075),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              if (showDecision)
                Positioned(
                  top: 22,
                  left: isInterested ? 20 : null,
                  right: isInterested ? null : 20,
                  child: _DecisionStamp(
                    label: isInterested
                        ? widget.interestedLabel
                        : widget.notInterestedLabel,
                    icon: isInterested
                        ? Icons.bookmark_add_rounded
                        : Icons.close_rounded,
                    color: isInterested
                        ? const Color(0xFF39C987)
                        : const Color(0xFFE35D6A),
                    opacity: progress.abs(),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _DecisionStamp extends StatelessWidget {
  const _DecisionStamp({
    required this.label,
    required this.icon,
    required this.color,
    required this.opacity,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity.clamp(0.25, 1.0),
    child: Transform.rotate(
      angle: -0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xE6111319),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.24), blurRadius: 16),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SkipReasonTile extends StatelessWidget {
  const _SkipReasonTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.accentColor, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.color,
    required this.diameter,
    required this.onPressed,
  });
  final String tooltip;
  final String label;
  final IconData icon;
  final Color color;
  final double diameter;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: onPressed == null
                    ? null
                    : [
                        BoxShadow(
                          color: color.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
              ),
              child: Material(
                color: color.withValues(alpha: 0.12),
                shape: CircleBorder(
                  side: BorderSide(color: color.withValues(alpha: 0.55)),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: onPressed == null ? Colors.white24 : color,
                    size: diameter * 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 88,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: onPressed == null
                      ? Colors.white24
                      : Colors.white.withValues(alpha: 0.84),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SessionStat extends StatelessWidget {
  const _SessionStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            '$value',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({
    required this.onUndo,
    required this.onRefresh,
    required this.isLoading,
    required this.addedCount,
    required this.passedCount,
    required this.watchedCount,
    required this.preferredGenreIds,
  });
  final VoidCallback? onUndo;
  final VoidCallback? onRefresh;
  final bool isLoading;
  final int addedCount;
  final int passedCount;
  final int watchedCount;
  final List<int> preferredGenreIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.done_all_rounded,
              size: 64,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.swipeDeckFinished,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.swipeDeckFinishedHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            if (addedCount + passedCount + watchedCount > 0) ...[
              const SizedBox(height: 24),
              Text(
                l10n.swipeSessionSummary,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SessionStat(
                    icon: Icons.bookmark_added_rounded,
                    color: const Color(0xFF39C987),
                    value: addedCount,
                    label: l10n.swipeSessionAdded,
                  ),
                  const SizedBox(width: 10),
                  _SessionStat(
                    icon: Icons.close_rounded,
                    color: const Color(0xFFE35D6A),
                    value: passedCount,
                    label: l10n.swipeSessionPassed,
                  ),
                  const SizedBox(width: 10),
                  _SessionStat(
                    icon: Icons.visibility_rounded,
                    color: AppTheme.accentColor,
                    value: watchedCount,
                    label: l10n.swipeSessionWatched,
                  ),
                ],
              ),
              if (preferredGenreIds.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 17,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.swipeSessionTasteHint(
                            preferredGenreIds
                                .map((id) => genreName(l10n, id))
                                .join(' • '),
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (onUndo != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onUndo,
                icon: const Icon(Icons.undo_rounded),
                label: Text(l10n.swipeUndo),
              ),
            ],
            if (onRefresh != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(l10n.swipeLoadMore),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
