import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/social_repository.dart';
import '../../models/community_post_model.dart';

// Final step of every share flow — a mandatory caption, then a single write
// to the `posts` collection. This is the one place that actually creates a
// post: the picker sheets before it only gather WHAT to share (one movie,
// several diary entries, or a collection), never write anything themselves.
//
// 'movie' and 'diary_snapshot' embed a frozen snapshot here, once, never
// touched again — later diary edits must not change an already-published
// post. 'collection' is the deliberate exception: it only carries a
// reference (collectionRefId) to a live-synced shared_collections doc, and
// submitting here is also what turns that live sync on in the first place
// (see setCollectionVisibility).
class ShareComposeSheet extends ConsumerStatefulWidget {
  final String type; // 'movie' | 'diary_snapshot' | 'collection'
  final Map<String, dynamic>? moviePayload;
  final List<Map<String, dynamic>> entries;
  final Map<String, dynamic>? collectionPayload; // {listId, name, description}

  const ShareComposeSheet({
    super.key,
    required this.type,
    this.moviePayload,
    this.entries = const [],
    this.collectionPayload,
  });

  static void show(
    BuildContext context, {
    required String type,
    Map<String, dynamic>? moviePayload,
    List<Map<String, dynamic>> entries = const [],
    Map<String, dynamic>? collectionPayload,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ShareComposeSheet(
          type: type,
          moviePayload: moviePayload,
          entries: entries,
          collectionPayload: collectionPayload,
        ),
      ),
    );
  }

  @override
  ConsumerState<ShareComposeSheet> createState() => _ShareComposeSheetState();
}

class _ShareComposeSheetState extends ConsumerState<ShareComposeSheet> {
  final TextEditingController _captionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  bool get _isMovie => widget.type == 'movie';
  bool get _isCollection => widget.type == 'collection';

  @override
  Widget build(BuildContext context) {
    final canSubmit = _captionController.text.trim().isNotEmpty && !_submitting;

    return GlassContainer(
      borderRadius: 24,
      opacity: 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetHandle(),
          const SizedBox(height: 16),
          Text(
            _isMovie ? AppLocalizations.of(context).shareMovieTitle : (_isCollection ? AppLocalizations.of(context).shareCollectionTitle : AppLocalizations.of(context).shareDiaryTitle),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildPreview(),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            maxLines: 3,
            minLines: 2,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: _isMovie
                  ? AppLocalizations.of(context).shareComposeMovieHint
                  : (_isCollection ? AppLocalizations.of(context).shareComposeCollectionHint : AppLocalizations.of(context).shareComposeDiaryHint),
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: AppLocalizations.of(context).shareSubmit,
              isLoading: _submitting,
              onPressed: canSubmit ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_isMovie) {
      final payload = widget.moviePayload!;
      final poster = payload['moviePosterPath'] as String?;
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 36,
              height: 54,
              child: poster != null && poster.isNotEmpty
                  ? Image.network('${ApiConstants.imagePathW500}$poster', fit: BoxFit.cover)
                  : Container(color: AppColors.surface, child: const Icon(Icons.movie_rounded, color: AppColors.textTertiary, size: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              payload['movieTitle'] as String? ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (_isCollection) {
      final payload = widget.collectionPayload!;
      return Row(
        children: [
          const Icon(Icons.collections_bookmark_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              payload['name'] as String? ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      AppLocalizations.of(context).shareEntriesCount(widget.entries.length),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
    );
  }

  Future<void> _submit() async {
    final currentUser = ref.currentUser;
    if (currentUser == null) {
      showPremiumToast(context, AppLocalizations.of(context).shareSignInRequired, isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final identity = resolveUserIdentity(ref.read(userModelProvider), currentUser);
      final username = identity.username;
      final avatarUrl = identity.avatarUrl;
      final caption = _captionController.text.trim();

      CommunityPost post;
      if (_isMovie) {
        post = CommunityPost(
          id: '',
          userId: currentUser.uid,
          username: username,
          userAvatarUrl: avatarUrl,
          type: 'movie',
          caption: caption,
          createdAt: DateTime.now(),
          starredBy: const [],
          commentCount: 0,
          movieId: widget.moviePayload!['movieId'] as int,
          isTv: widget.moviePayload!['isTv'] as bool,
          movieTitle: widget.moviePayload!['movieTitle'] as String,
          moviePosterPath: widget.moviePayload!['moviePosterPath'] as String?,
          releaseYear: widget.moviePayload!['releaseYear'] as int?,
          rating: (widget.moviePayload!['rating'] as num?)?.toDouble(),
          mood: widget.moviePayload!['mood'] as String?,
          watchDate: widget.moviePayload!['watchDate'] as DateTime?,
        );
      } else if (_isCollection) {
        final listId = widget.collectionPayload!['listId'] as int;
        // Turns the collection's live sync on (writes the initial
        // shared_collections snapshot if it wasn't already shared) — this
        // is the one action that makes collectionRefId below resolve to
        // real data.
        await setCollectionVisibility(ref, listId, true);
        post = CommunityPost(
          id: '',
          userId: currentUser.uid,
          username: username,
          userAvatarUrl: avatarUrl,
          type: 'collection',
          caption: caption,
          createdAt: DateTime.now(),
          starredBy: const [],
          commentCount: 0,
          collectionRefId: '${currentUser.uid}_$listId',
        );
      } else {
        post = CommunityPost(
          id: '',
          userId: currentUser.uid,
          username: username,
          userAvatarUrl: avatarUrl,
          type: 'diary_snapshot',
          caption: caption,
          createdAt: DateTime.now(),
          starredBy: const [],
          commentCount: 0,
          entries: widget.entries,
        );
      }

      await ref.read(socialRepositoryProvider).publishPost(post);

      if (mounted) {
        showPremiumToast(context, AppLocalizations.of(context).shareSucceeded);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('post share failed: $e');
      if (mounted) {
        debugPrint('Sharing failed: $e');
        showPremiumToast(context, AppLocalizations.of(context).shareFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
