import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/dynamic_background_provider.dart';

// Deterministic per-poster gradient used while loading and when no real
// image is available, so placeholders read as an intentional stylized
// poster rather than a broken-image state. Same seed always yields the
// same hue; varying only lightness across the gradient stops.
LinearGradient posterPlaceholderGradient(String seed) {
  final hue = (seed.isEmpty ? 210 : seed.hashCode % 360).abs().toDouble();
  const saturation = 0.5;
  return LinearGradient(
    begin: const Alignment(-0.7, -1),
    end: const Alignment(0.7, 1),
    colors: [
      HSLColor.fromAHSL(1, hue, saturation, 0.14).toColor(),
      HSLColor.fromAHSL(1, hue, saturation, 0.30).toColor(),
      HSLColor.fromAHSL(1, hue, saturation, 0.46).toColor(),
    ],
    stops: const [0.0, 0.55, 1.0],
  );
}

class AppNetworkImage extends ConsumerStatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  // Optional explicit seed (e.g. movie title) for the placeholder gradient.
  // Falls back to imageUrl, which is already unique per poster when present.
  final String? seed;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.seed,
  });

  @override
  ConsumerState<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends ConsumerState<AppNetworkImage> {
  late final String _posterKey;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    }
    // Unique key for tracking this poster instance in the background provider.
    _posterKey = widget.imageUrl.isNotEmpty
        ? widget.imageUrl
        : (widget.seed ?? 'image_${identityHashCode(this)}');
  }

  @override
  void dispose() {
    // Unregister this poster's color immediately on dispose to avoid color leak
    // when navigating away from the page.
    try {
      ref.read(dynamicBackgroundProvider.notifier).unregisterPoster(_posterKey);
    } catch (e) {
      debugPrint('Error unregistering poster color in dispose: $e');
    }
    super.dispose();
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(gradient: posterPlaceholderGradient(widget.seed ?? widget.imageUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String finalUrl = widget.imageUrl;
    if (kIsWeb && finalUrl.isNotEmpty) {
      finalUrl = finalUrl.contains('?') ? '$finalUrl&cors=1' : '$finalUrl?cors=1';
    }

    Widget childWidget;

    if (finalUrl.isEmpty) {
      childWidget = SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.errorWidget ?? _gradientPlaceholder(),
      );
    } else if (kIsWeb) {
      childWidget = Image.network(
        finalUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: widget.placeholder ?? _gradientPlaceholder(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: widget.errorWidget ?? _gradientPlaceholder(),
          );
        },
      );
    } else {
      childWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.placeholder ?? _gradientPlaceholder(),
        ),
        errorWidget: (context, url, error) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.errorWidget ?? _gradientPlaceholder(),
        ),
      );
    }

    return VisibilityDetector(
      key: ValueKey(_posterKey),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        // If more than 10% of the poster is visible, register it to the dynamic background.
        if (visiblePercentage >= 10.0) {
          ref.read(dynamicBackgroundProvider.notifier).registerPoster(
                _posterKey,
                imageUrl: widget.imageUrl,
                seed: widget.seed,
              );
        } else {
          // Otherwise, unregister it.
          ref.read(dynamicBackgroundProvider.notifier).unregisterPoster(_posterKey);
        }
      },
      child: childWidget,
    );
  }
}
