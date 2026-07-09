import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class AppNetworkImage extends StatelessWidget {
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

  Widget _gradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(gradient: posterPlaceholderGradient(seed ?? imageUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String finalUrl = imageUrl;
    if (kIsWeb && finalUrl.isNotEmpty) {
      finalUrl = finalUrl.contains('?') ? '$finalUrl&cors=1' : '$finalUrl?cors=1';
    }

    if (finalUrl.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: errorWidget ?? _gradientPlaceholder(),
      );
    }

    if (kIsWeb) {
      return Image.network(
        finalUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: placeholder ?? _gradientPlaceholder(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: errorWidget ?? _gradientPlaceholder(),
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => SizedBox(
        width: width,
        height: height,
        child: placeholder ?? _gradientPlaceholder(),
      ),
      errorWidget: (context, url, error) => SizedBox(
        width: width,
        height: height,
        child: errorWidget ?? _gradientPlaceholder(),
      ),
    );
  }
}
