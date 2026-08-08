import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../main_shell.dart';
import '../../../onboarding/presentation/onboarding_screen.dart';
import '../../../settings/presentation/settings_provider.dart';

class FirstSessionChecklistCard extends ConsumerWidget {
  const FirstSessionChecklistCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDismissed = ref.watch(firstSessionChecklistDismissedProvider);
    if (isDismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final records = ref.watch(allWatchRecordsProvider).value ?? const [];
    final favorites = ref.watch(favoriteMovieIdsProvider).value ?? const {};
    final customLists = ref.watch(customListsProvider).value ?? const [];
    final followedUsers = ref.watch(followedUserIdsProvider).value ?? const {};

    final step1Done = onboardingCompleted;
    final step2Done = records.isNotEmpty;
    final step3Done = favorites.isNotEmpty;
    final step4Done = customLists.isNotEmpty || followedUsers.isNotEmpty;

    final steps = [step1Done, step2Done, step3Done, step4Done];
    final completedCount = steps.where((done) => done).length;

    // Auto-hide when all 4 steps are complete
    if (completedCount == 4) return const SizedBox.shrink();

    final progress = completedCount / 4;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.checklistTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  l10n.checklistProgress(completedCount, 4),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    ref
                        .read(firstSessionChecklistDismissedProvider.notifier)
                        .setDismissed(true);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Steps List
            _buildStepTile(
              context: context,
              icon: Icons.tune_rounded,
              title: l10n.checklistStep1,
              isDone: step1Done,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(isModal: true),
                  ),
                );
              },
            ),
            _buildStepTile(
              context: context,
              icon: Icons.bookmark_add_rounded,
              title: l10n.checklistStep2,
              isDone: step2Done,
              onTap: () {
                ref.read(mainShellTabIndexProvider.notifier).state = 1;
              },
            ),
            _buildStepTile(
              context: context,
              icon: Icons.favorite_rounded,
              title: l10n.checklistStep3,
              isDone: step3Done,
              onTap: () {
                ref.read(mainShellTabIndexProvider.notifier).state = 1;
              },
            ),
            _buildStepTile(
              context: context,
              icon: Icons.collections_bookmark_rounded,
              title: l10n.checklistStep4,
              isDone: step4Done,
              onTap: () {
                ref.read(mainShellTabIndexProvider.notifier).state = 2;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return AppPressable(
      onTap: isDone ? null : onTap,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: isDone ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            icon,
            size: 18,
            color: isDone ? AppColors.textSecondary : Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDone ? AppColors.textSecondary : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (!isDone)
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
