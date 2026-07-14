import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../controllers/auth_controller.dart';

class ProfileActionsCard extends ConsumerWidget {
  final VoidCallback onEditPressed;
  const ProfileActionsCard({super.key, required this.onEditPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline_rounded, color: Colors.white70),
            title: const Text('Profili Düzenle'),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: onEditPressed,
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
                  backgroundColor: AppTheme.surfaceColor,
                  title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                  content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
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
                Navigator.of(context).pop();
                await ref.read(authControllerProvider).signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
