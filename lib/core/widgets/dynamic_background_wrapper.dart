import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/dynamic_background_provider.dart';

/// Wraps a widget with a dynamic, blurred, mesh-gradient background.
/// Renders a solid dark color when disabled or when no colors are active.
class DynamicBackgroundWrapper extends ConsumerWidget {
  final Widget child;

  const DynamicBackgroundWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgState = ref.watch(dynamicBackgroundProvider);
    final activeColors = bgState.uniqueColors;

    if (!bgState.isEnabled || activeColors.isEmpty) {
      // Fallback: Default Premium Dark Background
      return Container(
        color: AppTheme.backgroundColor,
        child: child,
      );
    }

    // Distribute active colors deterministically to 4 corners/sides
    final color1 = _getBlobColor(0, activeColors);
    final color2 = _getBlobColor(1, activeColors);
    final color3 = _getBlobColor(2, activeColors);
    final color4 = _getBlobColor(3, activeColors);

    return Stack(
      children: [
        // 1. Deep Cinematic Dark Base Layer
        Container(
          color: AppTheme.backgroundColor,
        ),

        // 2. Radial Gradient Layers (Web-safe & high-performance mesh gradient)
        // Top-Left Glow
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.3,
                colors: [
                  color1.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Middle-Right Glow
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.3),
                radius: 1.1,
                colors: [
                  color2.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Middle-Left Glow
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, 0.3),
                radius: 1.1,
                colors: [
                  color3.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-Right Glow
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.3,
                colors: [
                  color4.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3. Subdued Dimming Overlay to ensure text readability
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ),

        // 4. Content Page
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Color _getBlobColor(int index, List<Color> colors) {
    if (colors.isEmpty) return Colors.transparent;
    return colors[index % colors.length];
  }
}
