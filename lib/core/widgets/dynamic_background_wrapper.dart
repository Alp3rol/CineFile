import 'dart:ui';
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

    final size = MediaQuery.of(context).size;
    final height = size.height;

    // Distribute active colors deterministically to 4 blobs
    final color1 = _getBlobColor(0, activeColors);
    final color2 = _getBlobColor(1, activeColors);
    final color3 = _getBlobColor(2, activeColors);
    final color4 = _getBlobColor(3, activeColors);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Deep Cinematic Dark Base Layer
          Container(
            color: AppTheme.backgroundColor,
          ),

          // 2. Animated Blobs
          // Blob 1: Top-Left
          Positioned(
            top: -150,
            left: -150,
            child: _buildBlob(color1, 400),
          ),

          // Blob 2: Middle-Right
          Positioned(
            top: height * 0.15,
            right: -180,
            child: _buildBlob(color2, 380),
          ),

          // Blob 3: Middle-Left
          Positioned(
            bottom: height * 0.15,
            left: -180,
            child: _buildBlob(color3, 380),
          ),

          // Blob 4: Bottom-Right
          Positioned(
            bottom: -150,
            right: -150,
            child: _buildBlob(color4, 400),
          ),

          // 3. Heavy Blur Filter and Dimming Overlay to ensure text readability
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 95.0, sigmaY: 95.0),
              child: Container(
                color: Colors.black.withOpacity(0.18), // High readability overlay
              ),
            ),
          ),

          // 4. Content Page
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double diameter) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
      ),
    );
  }

  Color _getBlobColor(int index, List<Color> colors) {
    if (colors.isEmpty) return Colors.transparent;
    return colors[index % colors.length];
  }
}
