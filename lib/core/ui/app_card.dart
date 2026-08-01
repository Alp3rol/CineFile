import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_pressable.dart';

/// Emphasis level of a card's surface.
enum AppCardTone {
  /// Sits on the screen background. The default.
  surface,

  /// Nested inside another card, or a selected row.
  raised,

  /// No fill — just the border. For grouping without adding visual weight.
  outline,

  /// A wash of white rather than an opaque fill, so whatever is behind shows
  /// through. For surfaces that sit on artwork or on the poster-derived
  /// dynamic background, where an opaque panel would punch a hole in it.
  /// The home dashboard wrote this three times at three different alpha
  /// pairs (0.03/0.06, 0.04/0.10, 0.05/0.10) for the same intent.
  translucent,
}

/// A bordered, rounded surface.
///
/// Targets the 177 inline `BoxDecoration`s in feature code, most of which are
/// this exact thing rebuilt from scratch: a surface colour, a hairline border,
/// a radius and some padding.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = AppCardTone.surface,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.borderRadius = AppRadius.lg,
    this.elevated = false,
    this.borderColor,
  });

  final Widget child;
  final AppCardTone tone;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;

  /// Adds a drop shadow. Off by default — on a dark theme shadows read as
  /// grime unless the surface genuinely floats.
  final bool elevated;

  /// Overrides the hairline border, for cards that carry a status colour
  /// (a selected list, an error state).
  final Color? borderColor;

  Color get _fill => switch (tone) {
        AppCardTone.surface => AppColors.surface,
        AppCardTone.raised => AppColors.surfaceRaised,
        AppCardTone.outline => AppColors.transparent,
        AppCardTone.translucent =>
          AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
      };

  /// A translucent card needs a brighter hairline than the standard one: at 6%
  /// the border disappears against the lighter fill it now sits on.
  Color get _border => switch (tone) {
        AppCardTone.translucent =>
          AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
        _ => AppColors.border,
      };

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? _border,
          width: AppSize.hairline,
        ),
        boxShadow: elevated ? AppElevation.low(AppColors.shadow) : null,
      ),
      // Clip so a poster or gradient child cannot paint over the rounded
      // corners — the most common reason a hand-rolled card looks subtly off.
      clipBehavior: Clip.antiAlias,
      child: AppPressable(
        onTap: onTap,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A titled block within a screen, optionally with a trailing action.
///
/// Every screen currently builds its own section header — a `Row` with a
/// `GoogleFonts.outfit(...)` title and sometimes a "see all" button — with the
/// title size varying between 16, 17 and 18 depending on the screen. This
/// fixes the header and leaves the body to the caller.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Applied to the header only, so the body can run edge-to-edge — the
  /// horizontally scrolling poster rows need to bleed past the screen inset.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}
