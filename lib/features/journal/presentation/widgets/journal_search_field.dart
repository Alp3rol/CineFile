import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';

// Collapsible search field shown under JournalScreen's tab bar when the
// search icon in the top banner is toggled on.
class JournalSearchField extends StatelessWidget {
  final bool visible;
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const JournalSearchField({
    super.key,
    required this.visible,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 0),
      secondChild: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xs,
        ),
        child: TextField(
          controller: controller,
          autofocus: true,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textPrimary),
          onChanged: onChanged,
          // Fill, border, radius and hint style all come from
          // inputDecorationTheme now; only what is specific to this field is
          // stated — its icons and its tighter vertical padding.
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).journalSearchHint,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: AppSize.iconMd,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: AppSize.iconMd),
                    onPressed: onClear,
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
      ),
      crossFadeState:
          visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: AppDuration.normal,
    );
  }
}
