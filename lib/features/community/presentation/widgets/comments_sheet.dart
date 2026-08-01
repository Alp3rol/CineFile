import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../auth/presentation/user_profile_screen.dart';
import '../../data/social_repository.dart';
import '../comments_provider.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CommentsSheet(postId: postId),
        );
      },
    );
  }

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();

    // Identity is resolved by the repository, not passed in: firestore.rules
    // requires the stamped username/avatar to equal the caller's profile, so
    // there must be exactly one place that decides what they are.
    await ref.read(socialRepositoryProvider).addComment(
          postId: widget.postId,
          text: text,
        );

    // Scroll to bottom
    if (_scrollController.hasClients) {
      unawaited(_scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ));
    }
  }

  Future<void> _deleteComment(String commentId) async {
    await ref.read(socialRepositoryProvider).deleteComment(
          postId: widget.postId,
          commentId: commentId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;


    return GlassContainer(
      borderRadius: 24,
      opacity: 0.93,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSheetHandle(),
            const SizedBox(height: AppSpacing.md),
            
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commentsAsync.when(
                  loading: () => Text(AppLocalizations.of(context).commentsTitle, style: Theme.of(context).textTheme.titleLarge),
                  error: (err, stack) => Text(AppLocalizations.of(context).commentsTitle, style: Theme.of(context).textTheme.titleLarge),
                  data: (comments) => Text(
                    AppLocalizations.of(context).commentsTitleWithCount(comments.length),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.border),
            
            // Comments List
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                error: (err, stack) => Center(child: Text(AppLocalizations.of(context).commentsLoadFailed, style: const TextStyle(color: AppColors.error))),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).commentsEmpty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isOwner = currentUser != null && comment.userId == currentUser.uid;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(userId: comment.userId),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.surface,
                                backgroundImage: NetworkImage(comment.userAvatarUrl),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => UserProfileScreen(userId: comment.userId),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          comment.username.isEmpty
                                              ? AppLocalizations.of(context).userUnknown
                                              : comment.username,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatRelativeTime(context, comment.createdAt),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textTertiary, size: 16),
                                onPressed: () {
                                  // Show brief confirm dialog
                                  showDialog(
                                    context: context,
                                    builder: (dialogCtx) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      title: Text(AppLocalizations.of(context).commentsDeleteTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
                                      content: Text(AppLocalizations.of(context).commentsDeleteConfirm, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogCtx),
                                          child: Text(AppLocalizations.of(context).commonCancel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogCtx);
                                            _deleteComment(comment.id);
                                          },
                                          child: Text(AppLocalizations.of(context).commonDelete, style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const Divider(color: AppColors.border),
            
            // Text Input Row
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _commentController,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: currentUser != null ? AppLocalizations.of(context).commentsHint : AppLocalizations.of(context).commentsSignInHint,
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                        ),
                        enabled: currentUser != null,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (currentUser != null) {
                            _submitComment();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: currentUser != null 
                        ? _submitComment
                        : null,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: currentUser != null ? AppColors.accent : AppColors.border,
                      child: Icon(
                        Icons.send_rounded, 
                        color: currentUser != null ? AppColors.textPrimary : AppColors.textTertiary, 
                        size: 18
                      ),
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
