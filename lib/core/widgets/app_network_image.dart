import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // Image.network has no memory-cache-size knob on web, but cacheWidth/
      // cacheHeight still tell the decoder to downsample instead of
      // decoding at the source image's full resolution. Callers sometimes
      // pass width: double.infinity to fill a flexible parent (e.g. search
      // grid tiles) — isFinite guards against Infinity.round() throwing.
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final hasFiniteWidth = widget.width != null && widget.width!.isFinite;
      final hasFiniteHeight = widget.height != null && widget.height!.isFinite;
      childWidget = Image.network(
        finalUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: hasFiniteWidth ? (widget.width! * dpr).round() : null,
        cacheHeight: hasFiniteHeight ? (widget.height! * dpr).round() : null,
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
      // Decoding a poster/backdrop at its full TMDb resolution (e.g. w500
      // or "original") when it's displayed at a fraction of that size wastes
      // memory and CPU on every scroll/rebuild. memCacheWidth/Height tell
      // the decoder to downsample to roughly the on-screen size instead.
      // Callers sometimes pass width: double.infinity to fill a flexible
      // parent (e.g. search grid tiles) — isFinite guards against
      // Infinity.round() throwing.
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final hasFiniteWidth = widget.width != null && widget.width!.isFinite;
      final hasFiniteHeight = widget.height != null && widget.height!.isFinite;
      childWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        memCacheWidth: hasFiniteWidth ? (widget.width! * dpr).round() : null,
        memCacheHeight: hasFiniteHeight ? (widget.height! * dpr).round() : null,
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

    return childWidget;
  }
}
