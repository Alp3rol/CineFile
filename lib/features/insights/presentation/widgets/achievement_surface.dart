import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';

/// The indigo → violet → navy panel gradient behind the achievement surfaces.
///
/// Written out twice before this, in the achievements grid and the badge
/// dialog, with the same first and last stop and a slightly different middle
/// one. The alphas differed too (0.85/0.85/0.95 against 0.95/0.95/0.98), which
/// is the sort of difference nobody chose — it is what a copy-paste looks like
/// after one side gets nudged.
const achievementPanelGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.surfaceIndigo,
    AppColors.surfaceViolet,
    AppColors.surfaceNavy,
  ],
);

/// The gold call-to-action gradient on the achievements header.
///
/// Its stops were `0xFFFFD700 → 0xFFFF8C00`, which is the detail screen's
/// diary-action gradient with a slightly different start — a fifth variant of
/// what is one treatment. It uses the named pair now.
const achievementHighlightGradient = LinearGradient(
  colors: [AppColors.accentWarmStart, AppColors.accentWarmEnd],
);
