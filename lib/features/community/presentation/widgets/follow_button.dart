import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/controllers/auth_controller.dart';

// Shared "Takip Et" / "Takibi Bırak" pill button, used on the profile screen
// and in user search results so the follow/unfollow visuals and error
// handling live in exactly one place.
class FollowButton extends ConsumerWidget {
  final String targetUserId;
  const FollowButton({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const SizedBox();

    return ref.watch(isFollowingProvider(targetUserId)).when(
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: AppTheme.accentColor, strokeWidth: 2),
      ),
      error: (err, stack) => const SizedBox(),
      data: (isFollowing) => GestureDetector(
        onTap: () async {
          try {
            await toggleFollow(
              ref,
              currentUserId: currentUser.uid,
              targetUserId: targetUserId,
              currentlyFollowing: isFollowing,
            );
          } catch (e) {
            debugPrint('toggleFollow failed: $e');
            if (context.mounted) {
              showPremiumToast(context, 'Takip durumu güncellenemedi: $e', isError: true);
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isFollowing ? Colors.transparent : AppTheme.accentColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFollowing ? Colors.white24 : AppTheme.accentColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              isFollowing ? 'Takibi Bırak' : 'Takip Et',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
