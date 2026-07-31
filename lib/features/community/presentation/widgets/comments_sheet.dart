import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
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
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commentsAsync.when(
                  loading: () => Text(AppLocalizations.of(context).commentsTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  error: (err, stack) => Text(AppLocalizations.of(context).commentsTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  data: (comments) => Text(
                    AppLocalizations.of(context).commentsTitleWithCount(comments.length),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            
            // Comments List
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                error: (err, stack) => Center(child: Text(AppLocalizations.of(context).commentsLoadFailed, style: const TextStyle(color: Colors.redAccent))),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).commentsEmpty,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
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
                                backgroundColor: AppTheme.surfaceColor,
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
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatRelativeTime(context, comment.createdAt),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 16),
                                onPressed: () {
                                  // Show brief confirm dialog
                                  showDialog(
                                    context: context,
                                    builder: (dialogCtx) => AlertDialog(
                                      backgroundColor: AppTheme.surfaceColor,
                                      title: Text(AppLocalizations.of(context).commentsDeleteTitle, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                                      content: Text(AppLocalizations.of(context).commentsDeleteConfirm, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogCtx),
                                          child: Text(AppLocalizations.of(context).commonCancel, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogCtx);
                                            _deleteComment(comment.id);
                                          },
                                          child: Text(AppLocalizations.of(context).commonDelete, style: TextStyle(color: Colors.redAccent)),
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
            
            const Divider(color: Colors.white10),
            
            // Text Input Row
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _commentController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: currentUser != null ? AppLocalizations.of(context).commentsHint : AppLocalizations.of(context).commentsSignInHint,
                          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
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
                      backgroundColor: currentUser != null ? AppTheme.accentColor : Colors.white10,
                      child: Icon(
                        Icons.send_rounded, 
                        color: currentUser != null ? Colors.white : Colors.white30, 
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
