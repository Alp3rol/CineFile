import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A tappable surface with consistent press feedback.
///
/// The codebase has 80 `GestureDetector`s and 14 `InkWell`s doing the same
/// job, which means most tappable things in the app give no press feedback at
/// all (`GestureDetector` draws nothing) while a minority ripple. This makes
/// the behaviour uniform and clips the ripple to the surface's own radius —
/// the detail that makes a hand-rolled `InkWell` look wrong on a rounded card.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = AppRadius.md,
    this.padding,
    /// Announced by screen readers in place of the child's own text. Set this
    /// whenever the child is icon-only.
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    // Non-interactive: skip the Material/InkWell machinery entirely rather
    // than paying for a layer that can never paint anything. Call sites pass a
    // null onTap for disabled rows often enough that this is worth doing.
    if (onTap == null && onLongPress == null) {
      return padding == null ? child : Padding(padding: padding!, child: child);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          splashColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          highlightColor:
              AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          hoverColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
