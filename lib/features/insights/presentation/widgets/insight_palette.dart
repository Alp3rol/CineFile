import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';

/// Categorical colours for the Insights charts.
///
/// A deliberate third domain palette, alongside `graph_style.dart` for the
/// relationship graph and `HeatmapColors` for the contribution grid. Chart
/// series are a different job from interface colour: they have to be
/// distinguishable from *each other* first, where [AppColors] entries have to
/// mean something. Reaching into the app palette for a fifth genre slice would
/// have it read as "the error one".
///
/// What this replaces is not a palette but the absence of one — the charts,
/// the seasonal bars, the time-of-day rows and the summary cards each picked
/// their own Material accents inline, so the same idea ("a second category")
/// was blueAccent in one place and lightBlueAccent in another.
abstract final class InsightPalette {
  /// Generic ramp for chart series, in the order slices should be assigned.
  /// Starts on the app's own accent and rating so the first two slices — the
  /// ones a user actually reads — belong to the app rather than to Material.
  static const List<Color> categorical = [
    AppColors.accent,
    _azure,
    AppColors.success,
    AppColors.rating,
    _violet,
  ];

  // Seasons. Named for what they are, not for their hue, so a palette change
  // does not turn "winter" into a lie.
  static const Color winter = _ice;
  static const Color spring = _leaf;
  static const Color summer = AppColors.rating;
  static const Color autumn = _ember;

  // Times of day.
  static const Color morning = _ember;
  static const Color midday = _azure;
  static const Color evening = _dusk;
  static const Color night = _violet;

  // Summary cards.
  static const Color summaryWatches = _azure;
  static const Color summaryTitles = _violet;
  static const Color summaryTime = _teal;

  static const Color _azure = Color(0xFF4C8DFF);
  static const Color _violet = Color(0xFFB06BFF);
  static const Color _teal = Color(0xFF3BD6C6);
  static const Color _ice = Color(0xFF6EC6FF);
  static const Color _leaf = Color(0xFF7BD88F);
  static const Color _ember = Color(0xFFFF8A50);
  static const Color _dusk = Color(0xFF6C7BFF);
}
