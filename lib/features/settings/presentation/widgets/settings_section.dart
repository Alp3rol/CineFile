import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';

/// The heading above a settings group.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppColors.accent),
      ),
    );
  }
}

/// A titled settings group: heading plus a glass card.
///
/// All three sections on the settings screen wrote this pairing out
/// themselves, each repeating the same card radius and opacity. Two of them
/// pad their contents; the preferences card does not, because its rows run
/// edge to edge and pad themselves — hence [padding] rather than a fixed inset.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          padding: padding,
          borderRadius: AppRadius.lg,
          child: child,
        ),
      ],
    );
  }
}

/// Title and explanatory line at the top of a settings card.
class SettingsCardIntro extends StatelessWidget {
  const SettingsCardIntro({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: theme.textTheme.labelMedium?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}
