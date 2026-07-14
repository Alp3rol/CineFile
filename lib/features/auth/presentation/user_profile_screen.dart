import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_provider.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/featured_showcase_section.dart';
import 'widgets/premium_featured_selector_dialog.dart';
import 'widgets/profile_actions_card.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/recent_watches_grid.dart';

class UserProfileScreen extends ConsumerWidget {
  final String? userId;
  const UserProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    final effectiveUserId = userId ?? currentUser?.uid;

    if (effectiveUserId == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Text(
            'Lütfen giriş yapın.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final userModelAsync = ref.watch(userModelStreamProvider(effectiveUserId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: userModelAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Hata: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (userModel) {
            if (userModel == null) {
              return const Center(
                child: Text(
                  'Kullanıcı bulunamadı.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final isMe = currentUser != null && currentUser.uid == effectiveUserId;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeaderCard(
                    userModel: userModel,
                    isMe: isMe,
                    showFollowButton: !isMe && currentUser != null,
                    targetUserId: effectiveUserId,
                    onEditPressed: () => _showEditProfileSheet(context, userModel),
                  ),
                  const SizedBox(height: 32),
                  FeaturedShowcaseSection(
                    userModel: userModel,
                    isMe: isMe,
                    onEditPressed: () => _showFeaturedMoviesSelector(context, ref, userModel),
                  ),
                  RecentWatchesGrid(userId: effectiveUserId),
                  if (isMe) ...[
                    const SizedBox(height: 32),
                    ProfileActionsCard(
                      onEditPressed: () => _showEditProfileSheet(context, userModel),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditProfileSheet(user: user);
      },
    );
  }

  void _showFeaturedMoviesSelector(BuildContext context, WidgetRef ref, UserModel userModel) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final recordsAsync = ref.watch(watchRecordsForUserProvider(userModel.id));
            return recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
              error: (err, stack) => AlertDialog(
                backgroundColor: AppTheme.surfaceColor,
                content: Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (records) {
                return PremiumFeaturedSelectorDialog(
                  records: records,
                  initialSelectedIds: userModel.featuredMovieIds,
                  onSave: (selectedIds) async {
                    await ref.read(authControllerProvider).updateProfile(
                      username: userModel.username,
                      avatarUrl: userModel.avatarUrl,
                      bio: userModel.bio,
                      featuredMovieIds: selectedIds,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
