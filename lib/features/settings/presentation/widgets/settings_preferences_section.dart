import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/notification_service.dart';
import '../settings_provider.dart';
import 'settings_section_header.dart';

// "Tercihler" card: release-reminders and dynamic-background toggles.
class SettingsPreferencesSection extends ConsumerWidget {
  const SettingsPreferencesSection({super.key});

  Widget _divider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borderColor);
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String label,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
            Text(
              trailingText,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Tercihler'),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 4),
          borderRadius: 16,
          opacity: 0.6,
          child: Column(
            children: [
              _toggleRow(
                icon: Icons.notifications_active_outlined,
                label: 'Çıkış Hatırlatıcıları',
                value: ref.watch(releaseRemindersEnabledProvider),
                onChanged: (v) async {
                  if (v) {
                    final messenger = ScaffoldMessenger.of(context);
                    final granted = await ref.read(notificationServiceProvider).requestPermissions();
                    if (granted) {
                      await ref.read(releaseRemindersEnabledProvider.notifier).savePreference(true);
                      await ref.read(notificationServiceProvider).syncNotifications();
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Bildirim izni reddedildi. Sistem ayarlarından açabilirsiniz.')),
                      );
                    }
                  } else {
                    await ref.read(releaseRemindersEnabledProvider.notifier).savePreference(false);
                    await ref.read(notificationServiceProvider).syncNotifications();
                  }
                },
              ),
              _divider(),
              _toggleRow(
                icon: Icons.palette_outlined,
                label: 'Dinamik Arka Plan',
                value: ref.watch(dynamicBackgroundEnabledProvider),
                onChanged: (v) => ref.read(dynamicBackgroundEnabledProvider.notifier).setEnabled(v),
              ),
              _divider(),
              _navRow(
                icon: Icons.language_rounded,
                label: 'Dil',
                trailingText: 'Türkçe',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diğer diller yakında eklenecek.')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
