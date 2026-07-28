import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../controllers/auth_controller.dart';

class ProfileActionsCard extends ConsumerWidget {
  final VoidCallback onEditPressed;
  const ProfileActionsCard({super.key, required this.onEditPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline_rounded, color: Colors.white70),
            title: Text(l10n.profileEdit),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: onEditPressed,
          ),
          const Divider(color: AppTheme.borderColor),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppTheme.accentColor),
            title: Text(
              l10n.profileSignOut,
              style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.surfaceColor,
                  title: Text(l10n.profileSignOut, style: const TextStyle(color: Colors.white)),
                  content: Text(l10n.profileSignOutConfirm, style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.profileSignOut, style: const TextStyle(color: AppTheme.accentColor)),
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
