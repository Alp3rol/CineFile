import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider);

    if (userModel == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      );
    }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // User Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentColor, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(
                        userModel.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${userModel.username}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Username
              Text(
                '@${userModel.username}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                userModel.email,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Stats Row (Followers / Following)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Takipçi', '${userModel.followerCount}'),
                  Container(height: 30, width: 1, color: AppTheme.borderColor),
                  _buildStatColumn('Takip', '${userModel.followingCount}'),
                ],
              ),
              const SizedBox(height: 40),

              // Profile Actions
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: Colors.white70),
                      title: const Text('Profili Düzenle (Yakında)'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                      onTap: () {
                        // TODO: Implement profile edit
                      },
                    ),
                    const Divider(color: AppTheme.borderColor),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppTheme.accentColor),
                      title: const Text(
                        'Çıkış Yap',
                        style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Çıkış Yap'),
                            content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.accentColor)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          // pop profile screen first to avoid context reference issues
                          Navigator.of(context).pop();
                          await ref.read(authControllerProvider).signOut();
                        }
                      },
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

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
