import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';

/// The chrome shared by both home heroes.
///
/// [HomeHeroBanner] and [HomeActiveHeroCarousel]'s slide were the same card
/// written twice: the same 360px height, the same 28px radius, the same
/// four-stop gradient with the same stops, the same top badge row and bottom
/// title block. They differed only in their border and glow colour, which is
/// what [accented] now selects. Keeping two copies is how the two heroes would
/// have drifted apart the first time one of them was tweaked.
///
/// The gradients and glows here are deliberate art, not accidental styling, so
/// they are preserved as-is rather than flattened onto the elevation scale.
class HomeHeroShell extends StatelessWidget {
  const HomeHeroShell({
    super.key,
    required this.backdropPath,
    required this.seed,
    required this.onTap,
    required this.top,
    required this.bottom,
    this.accented = false,
  });

  final String? backdropPath;

  /// Title, used to seed the placeholder gradient so a missing backdrop still
  /// renders the same colour every time for a given show.
  final String seed;

  final VoidCallback onTap;

  /// Badge row pinned to the top of the card.
  final Widget top;

  /// Title and actions pinned to the bottom.
  final Widget bottom;

  /// Draws the border and glow in the accent colour instead of neutral white.
  /// The continue-watching hero uses it to read as the more urgent of the two.
  final bool accented;

  static const double height = 360;

  /// Horizontal inset of the hero from the screen edge, on both sides.
  static const double _screenInset = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _screenInset),
      child: AppPressable(
        onTap: onTap,
        borderRadius: AppRadius.xl,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.allXl,
            border: Border.all(
              color: accented
                  ? AppColors.accent.withValues(alpha: AppOpacity.muted)
                  : AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
              width: AppSize.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: accented ? AppOpacity.soft : AppOpacity.faint,
                ),
                blurRadius: 26,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.allXl,
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: backdropPath != null
                        ? '${ApiConstants.imagePathW780}$backdropPath'
                        : '',
                    seed: seed,
                    width: MediaQuery.of(context).size.width - _screenInset * 2,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                  // Multi-stop cinematic gradient: a light top scrim so the
                  // badges read, a clear middle so the art shows, and a heavy
                  // base so the title and buttons sit on near-black.
                  //
                  // These alphas are off the opacity scale on purpose. They are
                  // tuned for text legibility over an arbitrary film still, not
                  // for surface hierarchy — snapping the base stop from 0.95 to
                  // the scale's 0.85 visibly weakens the title against a bright
                  // frame.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 0.65, 1.0],
                        colors: [
                          AppColors.shadow.withValues(alpha: 0.40),
                          AppColors.transparent,
                          AppColors.shadow.withValues(alpha: 0.65),
                          AppColors.shadow.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: top,
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A badge that sits on top of artwork.
///
/// Distinct from [AppBadge], which tints itself against a known surface
/// colour. Over a backdrop the surface is whatever the still happens to be, so
/// these carry their own dark scrim instead — a tinted-fill badge would be
/// unreadable over a bright frame.
class HeroBadge extends StatelessWidget {
  const HeroBadge({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.borderColor,
    this.glow = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final border =
        borderColor ?? AppColors.onImage.withValues(alpha: AppOpacity.soft);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.shadow.withValues(alpha: AppOpacity.strong),
        borderRadius: AppRadius.allPill,
        border: Border.all(color: border, width: AppSize.hairline),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: border.withValues(alpha: AppOpacity.muted),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.onImage, size: AppSize.iconSm),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onImage,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
          ),
        ],
      ),
    );
  }
}

/// The accent-gradient call to action at the base of a hero.
///
/// Both heroes drew this as a `GestureDetector` wrapping a decorated
/// `Container`, which meant it looked like a button but behaved like a piece
/// of coloured card: no press feedback, and nothing announcing it as a button
/// to a screen reader. It keeps the gradient and glow — those are the point —
/// and gains the behaviour.
class HeroActionButton extends StatelessWidget {
  const HeroActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.md,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent,
              AppColors.accent.withValues(alpha: AppOpacity.heavy),
            ],
          ),
          borderRadius: AppRadius.allMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: AppOpacity.medium),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.onAccent, size: AppSize.iconMd),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary action beside [HeroActionButton] — translucent rather than
/// filled, so it reads as the lesser of the two.
class HeroSecondaryButton extends StatelessWidget {
  const HeroSecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.md,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.onImage.withValues(alpha: AppOpacity.soft),
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: AppColors.onImage.withValues(alpha: AppOpacity.muted),
            width: AppSize.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accent, size: AppSize.iconSm),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onImage,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
