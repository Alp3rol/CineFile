import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../auth/presentation/widgets/user_profile_avatar_button.dart';
import 'journal_view_mode_toggle.dart';

// "Günlüğüm" title row: search toggle, card/table view toggle, profile avatar.
class JournalTopBanner extends StatelessWidget {
  final bool showSearch;
  final bool isTableView;
  final VoidCallback onToggleSearch;

  const JournalTopBanner({
    super.key,
    required this.showSearch,
    required this.isTableView,
    required this.onToggleSearch,
  });

  static const double _toggleDiameter = 36;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.journalTitle,
              style: Theme.of(context).textTheme.displayLarge),
          Row(
            children: [
              // Search toggle button
              AppPressable(
                onTap: onToggleSearch,
                borderRadius: AppRadius.pill,
                semanticLabel: l10n.journalSearchHint,
                child: Container(
                  width: _toggleDiameter,
                  height: _toggleDiameter,
                  decoration: BoxDecoration(
                    color: showSearch
                        ? AppColors.accent.withValues(alpha: AppOpacity.soft)
                        : AppColors.textPrimary
                            .withValues(alpha: AppOpacity.subtle),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    showSearch
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                    color: showSearch
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    size: AppSize.iconSm,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Card/Table view toggle — moved here from filter row
              JournalViewModeToggle(isTableView: isTableView),
              const SizedBox(width: AppSpacing.md),
              // Profile Avatar Button
              const UserProfileAvatarButton(),
            ],
          ),
        ],
      ),
    );
  }
}
