import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../core/database/database_provider.dart';
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
      backgroundColor: Colors.transparent,
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isMovie ? 'Film Paylaş' : (_isCollection ? 'Koleksiyon Paylaş' : 'Günlüğünü Paylaş'),
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildPreview(),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: _isMovie
                  ? 'Bu film hakkında ne düşünüyorsun?'
                  : (_isCollection ? 'Bu koleksiyon hakkında bir şeyler yaz...' : 'Bu günlük hakkında bir şeyler yaz...'),
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.accentColor.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Paylaş', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
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
                  : Container(color: AppTheme.surfaceColor, child: const Icon(Icons.movie_rounded, color: Colors.white24, size: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              payload['movieTitle'] as String? ?? '',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
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
          const Icon(Icons.collections_bookmark_outlined, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              payload['name'] as String? ?? '',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      '${widget.entries.length} kayıt paylaşılacak',
      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
    );
  }

  Future<void> _submit() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      showPremiumToast(context, 'Lütfen önce giriş yapın.', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final userModel = ref.read(userModelProvider);
      final username = userModel?.username ?? currentUser.email!.split('@')[0];
      final avatarUrl = userModel?.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=$username';
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

      await ref.read(firestoreProvider).collection('posts').add(post.toMap());

      if (mounted) {
        showPremiumToast(context, 'Paylaşıldı.');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('post share failed: $e');
      if (mounted) {
        showPremiumToast(context, 'Paylaşılamadı: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
