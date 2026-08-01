import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blurX;
  final double blurY;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Color? color;
  final double? width;
  final double? height;
  // When false, skips the BackdropFilter blur pass and just paints a flat
  // semi-transparent fill instead. Real backdrop blur is expensive per
  // instance (its own compositing layer + re-sampling every frame it's on
  // screen); for small elements that repeat per list item (poster rating
  // badges, per-row cards) that cost multiplies across every visible item
  // with no perceptible visual gain, so those call sites should pass false.
  // Large, few-per-screen panels (hero banners, stat cards, the bottom nav)
  // should keep the default blur.
  final bool useBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.blurX = AppBlur.md,
    this.blurY = AppBlur.md,
    this.opacity = AppOpacity.strong,
    this.borderRadius = AppRadius.lg,
    this.padding,
    this.margin,
    this.border,
    this.color,
    this.width,
    this.height,
    this.useBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: (color ?? AppColors.surface).withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: AppColors.border,
          width: AppSize.hairline,
        ),
      ),
      // Widgets that paint on "the nearest Material ancestor" (ListTile,
      // InkWell ripples, etc.) would otherwise paint underneath this
      // Container's own background color and become invisible — wrap
      // the content in its own transparent Material so those effects
      // render on top of it instead.
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: AppElevation.high(AppColors.shadow),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: useBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
                child: content,
              )
            : content,
      ),
    );
  }
}
