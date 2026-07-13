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
    final hasColors = bgState.isEnabled && activeColors.isNotEmpty;

    // Always render the same Stack shape (with `child` at the same position)
    // regardless of whether colors are active. Poster color extraction is
    // async, so this state flips mid-scroll on screens like movie detail —
    // switching between a Container and a Stack here would change the
    // widget type at this tree position, which makes Flutter destroy and
    // recreate everything below (including the page's ScrollController),
    // snapping the scroll position back to the top. Fading the gradient
    // layers to transparent keeps the child's Element — and its scroll
    // state — alive instead.
    final color1 = hasColors ? _getBlobColor(0, activeColors) : Colors.transparent;
    final color2 = hasColors ? _getBlobColor(1, activeColors) : Colors.transparent;
    final color3 = hasColors ? _getBlobColor(2, activeColors) : Colors.transparent;
    final color4 = hasColors ? _getBlobColor(3, activeColors) : Colors.transparent;

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
