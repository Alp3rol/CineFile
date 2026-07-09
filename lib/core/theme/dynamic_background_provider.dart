import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../constants/api_constants.dart';
import '../database/app_database.dart';
import '../../features/settings/presentation/settings_provider.dart';

/// State containing active poster colors and feature toggle status.
class DynamicBackgroundState {
  /// Map of posterKey -> Color
  final Map<String, Color> activePosterColors;
  final bool isEnabled;

  DynamicBackgroundState({
    required this.activePosterColors,
    required this.isEnabled,
  });

  DynamicBackgroundState copyWith({
    Map<String, Color>? activePosterColors,
    bool? isEnabled,
  }) {
    return DynamicBackgroundState(
      activePosterColors: activePosterColors ?? this.activePosterColors,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /// List of unique colors currently active on the screen.
  List<Color> get uniqueColors {
    if (!isEnabled || activePosterColors.isEmpty) {
      return const [];
    }
    // Maintain a unique list of colors
    return activePosterColors.values.toSet().toList();
  }
}

/// Global provider for managing dynamic background colors.
final dynamicBackgroundProvider = StateNotifierProvider<DynamicBackgroundNotifier, DynamicBackgroundState>((ref) {
  final isEnabled = ref.watch(dynamicBackgroundEnabledProvider);
  return DynamicBackgroundNotifier(isEnabled);
});

class DynamicBackgroundNotifier extends StateNotifier<DynamicBackgroundState> {
  DynamicBackgroundNotifier(bool isEnabled)
      : super(DynamicBackgroundState(
          activePosterColors: {},
          isEnabled: isEnabled,
        )) {
    if (kDebugMode) {
      final isWidgetTest = StackTrace.current.toString().contains('package:flutter_test') ||
          StackTrace.current.toString().contains('testWidgets');
      if (isWidgetTest) {
        VisibilityDetectorController.instance.updateInterval = Duration.zero;
      }
    }
  }

  // Static cache to store extracted colors across rebuilds and prevent repeated CPU-heavy color extractions.
  static final Map<String, Color> _colorCache = {};

  // Track currently visible keys on screen (so we don't add colors for images that scrolled off before extraction finished)
  final Set<String> _visibleKeys = {};

  /// Registers a poster to indicate it is currently visible on screen.
  /// Trigger color extraction asynchronously if not in cache.
  void registerPoster(String key, {String? imageUrl, String? seed}) {
    if (!state.isEnabled) return;
    
    _visibleKeys.add(key);

    // If we already have the color in cache, use it immediately
    if (_colorCache.containsKey(key)) {
      _updateActiveColor(key, _colorCache[key]!);
      return;
    }

    // Handle case where we don't have imageUrl but have a seed (placeholder gradient)
    if (imageUrl == null || imageUrl.isEmpty) {
      if (seed != null) {
        final color = _getPlaceholderColor(seed);
        _colorCache[key] = color;
        _updateActiveColor(key, color);
      }
      return;
    }

    // Extract color asynchronously
    _extractColor(key, imageUrl);
  }

  /// Unregisters a poster indicating it is no longer visible on screen.
  void unregisterPoster(String key) {
    _visibleKeys.remove(key);
    if (state.activePosterColors.containsKey(key)) {
      final updatedMap = Map<String, Color>.from(state.activePosterColors)..remove(key);
      state = state.copyWith(activePosterColors: updatedMap);
    }
  }

  void _updateActiveColor(String key, Color color) {
    if (!_visibleKeys.contains(key)) return; // Scrolled out before we could update
    
    final updatedMap = Map<String, Color>.from(state.activePosterColors)..[key] = color;
    state = state.copyWith(activePosterColors: updatedMap);
  }

  Future<void> _extractColor(String key, String imageUrl) async {
    try {
      ImageProvider imageProvider;
      if (kIsWeb) {
        // Apply CORS proxy if on web
        String finalUrl = imageUrl;
        finalUrl = finalUrl.contains('?') ? '$finalUrl&cors=1' : '$finalUrl?cors=1';
        imageProvider = NetworkImage(finalUrl);
      } else {
        imageProvider = CachedNetworkImageProvider(imageUrl);
      }

      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 5,
      );

      // Prefer dominant color, fallback to vibrant, fallback to any color
      final color = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          palette.colors.firstOrNull;

      if (color != null) {
        // Store in cache
        _colorCache[key] = color;
        // Apply if still visible
        _updateActiveColor(key, color);
      }
    } catch (e) {
      debugPrint('Error extracting color for key $key: $e. Falling back to HSL color.');
      final fallbackColor = _getPlaceholderColor(key);
      _colorCache[key] = fallbackColor;
      _updateActiveColor(key, fallbackColor);
    }
  }

  /// Directly updates the active colors based on a list of Movie database objects.
  void updateMoviesFromList(List<Movie> movies) {
    if (!state.isEnabled) return;

    _visibleKeys.clear();
    final Map<String, Color> activeColors = {};

    for (int i = 0; i < movies.length; i++) {
      final movie = movies[i];
      final imageUrl = movie.posterPath;
      final title = movie.title;

      String? finalImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        finalImageUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiConstants.imagePathW500}$imageUrl';
      }

      final key = finalImageUrl ?? title;
      _visibleKeys.add(key);

      if (_colorCache.containsKey(key)) {
        activeColors[key] = _colorCache[key]!;
      } else {
        // Fallback HSL color
        final fallbackColor = _getPlaceholderColor(title);
        _colorCache[key] = fallbackColor;
        activeColors[key] = fallbackColor;

        if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
          _extractColor(key, finalImageUrl);
        }
      }
    }

    state = state.copyWith(activePosterColors: activeColors);
  }

  /// Directly updates the active colors based on a list of TMDb Map objects.
  void updateMoviesFromMapList(List<Map<String, dynamic>> movies) {
    if (!state.isEnabled) return;

    _visibleKeys.clear();
    final Map<String, Color> activeColors = {};

    for (int i = 0; i < movies.length; i++) {
      final movie = movies[i];
      final imageUrl = movie['poster_path'] as String?;
      final title = movie['title'] as String? ?? movie['name'] as String? ?? 'movie_$i';

      String? finalImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        finalImageUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiConstants.imagePathW500}$imageUrl';
      }

      final key = finalImageUrl ?? title;
      _visibleKeys.add(key);

      if (_colorCache.containsKey(key)) {
        activeColors[key] = _colorCache[key]!;
      } else {
        // Fallback HSL color
        final fallbackColor = _getPlaceholderColor(title);
        _colorCache[key] = fallbackColor;
        activeColors[key] = fallbackColor;

        if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
          _extractColor(key, finalImageUrl);
        }
      }
    }

    state = state.copyWith(activePosterColors: activeColors);
  }

  /// Clears all active colors, resetting the background to the default solid dark theme.
  void clearColors() {
    _visibleKeys.clear();
    state = state.copyWith(activePosterColors: {});
  }

  /// Generates a deterministic average color for seed-based placeholders.
  Color _getPlaceholderColor(String seed) {
    final hue = (seed.isEmpty ? 210 : seed.hashCode % 360).abs().toDouble();
    // Middle color of the linear placeholder gradient:
    return HSLColor.fromAHSL(1, hue, 0.50, 0.30).toColor();
  }
}
