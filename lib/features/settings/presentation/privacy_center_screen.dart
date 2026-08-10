import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../swipe_discovery/data/swipe_preference_signal.dart';
import 'widgets/settings_backup_dialogs.dart';

class PrivacyCenterScreen extends ConsumerWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.privacyCenterTitle,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacyCenterSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Card 1: Local SQLite Data
                    _buildPrivacyCard(
                      context: context,
                      statusBadge: '🔒 Cihazda Saklanır',
                      statusColor: AppColors.accent,
                      icon: Icons.storage_rounded,
                      title: l10n.privacyLocalSection,
                      description: l10n.privacyLocalDesc,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Card 2: Cloud Firestore Sync
                    _buildPrivacyCard(
                      context: context,
                      statusBadge: '☁️ Bulutta Eşlenir',
                      statusColor: Colors.blueAccent,
                      icon: Icons.cloud_sync_rounded,
                      title: l10n.privacyCloudSection,
                      description: l10n.privacyCloudDesc,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Card 3: Community & Privacy Default
                    _buildPrivacyCard(
                      context: context,
                      statusBadge: '🌐 Seçimli Paylaşım',
                      statusColor: Colors.amberAccent,
                      icon: Icons.lock_person_rounded,
                      title: l10n.privacyPublicSection,
                      description: l10n.privacyPublicDesc,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      borderRadius: AppRadius.lg,
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.people_alt_rounded,
                          color: AppColors.accent,
                        ),
                        title: Text(
                          l10n.privacySwipeMatchingTitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          l10n.privacySwipeMatchingDesc,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        value:
                            ref.watch(swipeTasteSharingProvider).value ?? false,
                        onChanged: (enabled) =>
                            _setSwipeTasteSharing(context, ref, enabled),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Direct Action: Export JSON
                    AppButton(
                      label: l10n.privacyExportCTA,
                      icon: Icons.download_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: () => exportBackup(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Direct Action: Purge All Data
                    AppButton(
                      label: l10n.privacyDeleteAccountCTA,
                      icon: Icons.delete_forever_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _confirmPurgeAllData(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setSwipeTasteSharing(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final user = ref.currentUser;
    if (user == null) return;
    final profile = buildSwipeTasteProfile(
      ref.read(swipePreferenceSignalsProvider).value ?? const [],
    );
    try {
      await ref.read(firestoreProvider).collection('users').doc(user.uid).set({
        'shareSwipeTasteForMatching': enabled,
        'publicSwipeTasteGenreIds': enabled
            ? profile.genreIds
            : FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (context.mounted) {
        showPremiumToast(
          context,
          enabled
              ? AppLocalizations.of(context).privacySwipeMatchingEnabled
              : AppLocalizations.of(context).privacySwipeMatchingDisabled,
        );
      }
    } catch (_) {
      if (context.mounted) {
        showPremiumToast(context, AppLocalizations.of(context).swipeSaveFailed);
      }
    }
  }

  Future<void> _confirmPurgeAllData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.privacyDeleteConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.privacyDeleteConfirmDesc,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.delete(db.watchRecords).go();
      await db.delete(db.movies).go();
      if (context.mounted) {
        showPremiumToast(context, 'Tüm veriler cihazdan silindi.');
      }
    }
  }

  Widget _buildPrivacyCard({
    required BuildContext context,
    required String statusBadge,
    required Color statusColor,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusBadge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
