import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';
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
                    const SizedBox(height: AppSpacing.xxl),

                    // Direct Action: Export JSON
                    AppButton(
                      label: l10n.privacyExportCTA,
                      icon: Icons.download_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: () => exportBackup(context, ref),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
