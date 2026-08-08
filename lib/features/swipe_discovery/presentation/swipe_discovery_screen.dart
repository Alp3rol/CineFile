import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/movie_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../movie_detail/presentation/add_watch_record_sheet.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
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
  late List<Map<String, dynamic>> _remaining;
  final List<_SwipeAction> _history = [];
  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    _remaining = List<Map<String, dynamic>>.from(widget.items);
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
          duration: const Duration(milliseconds: 1200),
          content: Text(
            choice == _SwipeChoice.interested
                ? l10n.swipeAddedToWatchlist
                : l10n.swipePassed,
          ),
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
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddWatchRecordSheet(movieData: item),
    );
    if (saved == true && mounted) {
      setState(() => _remaining.remove(item));
    }
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
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }
      if (!mounted) return;
      setState(() {
        _history.clear();
        _remaining = List<Map<String, dynamic>>.from(widget.items);
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
      body: SafeArea(
        child: items.isEmpty
            ? _EmptyDeck(
                onUndo: _history.isEmpty ? null : _undo,
                onRefresh: widget.onRefresh == null ? null : _refreshDeck,
                isLoading: _isWriting,
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Column(
                      children: [
                        Text(
                          l10n.swipeDiscoverHint,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Text(
                            l10n.swipeRemaining(items.length),
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                                    child: _DiscoveryCard(item: items[1]),
                                  ),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            bottom: items.length > 1 ? 12 : 0,
                            child: Dismissible(
                              key: ValueKey('${_keyFor(items.first)}'),
                              direction: DismissDirection.horizontal,
                              background: _SwipeBackground(
                                alignment: Alignment.centerLeft,
                                color: const Color(0xFF168C5B),
                                icon: Icons.bookmark_add_rounded,
                                label: l10n.swipeInterested,
                              ),
                              secondaryBackground: _SwipeBackground(
                                alignment: Alignment.centerRight,
                                color: const Color(0xFF9E3540),
                                icon: Icons.close_rounded,
                                label: l10n.swipeNotInterested,
                              ),
                              onDismissed: (direction) => _choose(
                                items.first,
                                direction == DismissDirection.startToEnd
                                    ? _SwipeChoice.interested
                                    : _SwipeChoice.notInterested,
                              ),
                              child: _DiscoveryCard(item: items.first),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          tooltip: l10n.swipeNotInterested,
                          icon: Icons.close_rounded,
                          color: const Color(0xFFE35D6A),
                          onPressed: _isWriting
                              ? null
                              : () => _choose(
                                  items.first,
                                  _SwipeChoice.notInterested,
                                ),
                        ),
                        _ActionButton(
                          tooltip: l10n.swipeWatched,
                          icon: Icons.visibility_rounded,
                          color: AppTheme.accentColor,
                          size: 54,
                          onPressed: _isWriting
                              ? null
                              : () => _markWatched(items.first),
                        ),
                        _ActionButton(
                          tooltip: l10n.swipeInterested,
                          icon: Icons.bookmark_add_rounded,
                          color: const Color(0xFF39C987),
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
    );
  }
}

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

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 42),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 64,
  });
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.16),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        minimumSize: Size(size, size),
      ),
    ),
  );
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({
    required this.onUndo,
    required this.onRefresh,
    required this.isLoading,
  });
  final VoidCallback? onUndo;
  final VoidCallback? onRefresh;
  final bool isLoading;

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
