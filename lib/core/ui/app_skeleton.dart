import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A pulsing placeholder block for content that is still loading.
///
/// Written as a plain opacity pulse rather than a sweeping shimmer so it needs
/// no extra dependency and no gradient repaint per frame — these appear in
/// grids of a dozen or more at once, where a shimmer's cost multiplies.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = AppSpacing.lg,
    this.borderRadius = AppRadius.sm,
    this.shape = BoxShape.rectangle,
  });

  /// A circular skeleton for avatar placeholders. [borderRadius] is ignored
  /// when the shape is a circle.
  const AppSkeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      // Never fully transparent — a placeholder that disappears reads as a
      // layout bug rather than as loading.
      opacity: Tween<double>(
        begin: AppOpacity.muted,
        end: AppOpacity.strong,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
