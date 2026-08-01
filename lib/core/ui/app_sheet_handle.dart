import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// The grab bar at the top of a bottom sheet.
///
/// Flutter can draw this itself via `bottomSheetTheme.showDragHandle`, and
/// that setting is deliberately off — see the note on it in `app_theme.dart`.
/// The short version: eight sheets in this app draw their own, and at least
/// one of them (the add-watch-record sheet) depends on where it sits. Its
/// handle is outside the inner scroll view so a downward drag starting there
/// reaches the sheet's drag-to-dismiss gesture instead of being swallowed by
/// the scroll. Flutter's handle lives in its own header container and would
/// change that.
///
/// So the handle stays hand-placed, but there is now one of it rather than
/// eight — which is what made the theme flag look safe to turn on in the first
/// place.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  static const double _width = 40;
  static const double _height = 4;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: AppRadius.allPill,
        ),
      ),
    );
  }
}
