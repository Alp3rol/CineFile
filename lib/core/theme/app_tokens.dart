/// Design tokens: the measurement half of the design system.
///
/// These are deliberately colour-free. The palette lives in `app_colors.dart`
/// and is expected to be replaced wholesale when the visual identity changes;
/// these scales are not, because they encode rhythm rather than brand.
///
/// Every scale below was derived from the distribution of values already in
/// `lib/`, not invented — the goal was to cover the values that actually carry
/// weight and collapse the long tail. Where a screen currently uses an
/// off-scale value, migration snaps it to the nearest step; that is the point,
/// not a regression.
library;

import 'package:flutter/material.dart';

/// Spacing on a 4pt grid.
///
/// Replaces the 34 distinct `EdgeInsets` values in use. The heavy hitters were
/// 16 (×104), 20 (×79), 12 (×67), 8 (×63), 6 (×45), 10 (×37), 4 (×35),
/// 14 (×30), 24 (×26); the off-grid strays (3, 7, 18, 42, 0.5, 3.5) have no
/// step and snap to their neighbour.
///
/// Note that 20 has no step of its own: it sits between [lg] and [xl] and its
/// call sites split between them at migration time. Keeping a 20 step would
/// have preserved more pixels but kept the scale non-uniform, which is the
/// habit that produced 34 values in the first place.
abstract final class AppSpacing {
  /// 4 — icon-to-label gaps, chip inner padding.
  static const double xs = 4;

  /// 8 — tight stacks, list item internal gaps.
  static const double sm = 8;

  /// 12 — the default gap between siblings in a row or column.
  static const double md = 12;

  /// 16 — the standard screen edge inset and card padding.
  static const double lg = 16;

  /// 24 — gap between sections within a screen.
  static const double xl = 24;

  /// 32 — gap around a section header, sheet top padding.
  static const double xxl = 32;

  /// 48 — empty-state breathing room, screen top/bottom bookends.
  static const double xxxl = 48;
}

/// Corner radii.
///
/// Replaces 17 distinct values (2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 22, 24,
/// 28, 30, 100). Weighted by use: 12 (×57), 8 (×28), 16/14/10/2 (×20 each),
/// 20 (×19), 6 (×16).
abstract final class AppRadius {
  /// 4 — badges, tags, progress bars, anything small enough that a larger
  /// radius would eat the content.
  static const double xs = 4;

  /// 8 — inputs, compact buttons, inner surfaces nested in a card.
  static const double sm = 8;

  /// 12 — buttons and the default for most interactive surfaces.
  static const double md = 12;

  /// 16 — cards, sheets, poster tiles.
  static const double lg = 16;

  /// 24 — hero surfaces and modal bottom sheet tops.
  static const double xl = 24;

  /// Fully rounded. Large enough to always win against the shorter dimension,
  /// which is how the existing `100` call sites were already being used.
  static const double pill = 999;

  static BorderRadius allXs = BorderRadius.circular(xs);
  static BorderRadius allSm = BorderRadius.circular(sm);
  static BorderRadius allMd = BorderRadius.circular(md);
  static BorderRadius allLg = BorderRadius.circular(lg);
  static BorderRadius allXl = BorderRadius.circular(xl);
  static BorderRadius allPill = BorderRadius.circular(pill);

  /// Rounded top corners only — the modal bottom sheet shape.
  static const BorderRadius topXl = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Alpha steps, named by intent rather than by number.
///
/// Replaces the 34 distinct alpha values across 325 `withValues(alpha:)` call
/// sites. The clusters in the existing code map cleanly: 0.02–0.06 → [faint]
/// (66 uses), 0.08–0.12 → [subtle] (34), 0.15–0.20 → [soft] (57),
/// 0.25–0.35 → [muted] (39), 0.4–0.45 → [medium] (34), 0.5–0.7 → [strong] (43),
/// 0.75–0.98 → [heavy] (32).
///
/// Naming these by intent matters more than the values: `AppOpacity.disabled`
/// tells the next reader why, where `0.4` invites the next person to type
/// `0.45` because it looked slightly better on their screen.
abstract final class AppOpacity {
  /// 0.05 — hairline fills and tinted backgrounds that should read as texture.
  static const double faint = 0.05;

  /// 0.10 — resting state of a tinted surface, subtle dividers.
  static const double subtle = 0.10;

  /// 0.16 — hover and selection tints, icon backplates.
  static const double soft = 0.16;

  /// 0.30 — pressed states, secondary borders.
  static const double muted = 0.30;

  /// 0.40 — disabled content.
  static const double medium = 0.40;

  /// 0.60 — glass surface fills, scrims over imagery.
  static const double strong = 0.60;

  /// 0.85 — near-opaque overlays that still let the backdrop register.
  static const double heavy = 0.85;

  /// Semantic aliases. Prefer these at call sites where the intent is known —
  /// they survive a change to the underlying step.
  static const double disabled = medium;
  static const double scrim = strong;
  static const double overlay = heavy;
}

/// Shadow steps.
///
/// Replaces 48 hand-rolled [BoxShadow]s spread over 14 distinct `blurRadius`
/// values. Shadows are colour-bearing, so these take the shadow colour as an
/// argument rather than reaching into the palette — that keeps this file
/// palette-free and lets a light theme pass a different colour later.
abstract final class AppElevation {
  /// Resting card — barely there, just enough to lift off the background.
  static List<BoxShadow> low(Color shadow) => [
        BoxShadow(
          color: shadow.withValues(alpha: AppOpacity.soft),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Raised surface — sheets, popovers, floating action controls.
  static List<BoxShadow> medium(Color shadow) => [
        BoxShadow(
          color: shadow.withValues(alpha: AppOpacity.muted),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Hero surface — the large glass panels that anchor a screen.
  static List<BoxShadow> high(Color shadow) => [
        BoxShadow(
          color: shadow.withValues(alpha: AppOpacity.muted),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];
}

/// Blur sigmas for [BackdropFilter] surfaces.
///
/// Backdrop blur costs a compositing layer per instance, so the steps are
/// coarse on purpose — see the note on `GlassContainer.useBlur` for when to
/// skip the blur pass entirely rather than reach for a smaller sigma.
abstract final class AppBlur {
  static const double sm = 8;
  static const double md = 20;
  static const double lg = 40;
}

/// Motion durations.
///
/// Not previously centralised at all; collected here so the migration has
/// somewhere to put the animation constants it finds.
abstract final class AppDuration {
  /// State changes that should feel instant — tint, ripple, icon swap.
  static const Duration fast = Duration(milliseconds: 120);

  /// The default for anything the user is watching happen.
  static const Duration normal = Duration(milliseconds: 240);

  /// Entrances and page-level transitions.
  static const Duration slow = Duration(milliseconds: 400);

  /// Default easing. Emphasised, matching Material 3's standard curve.
  static const Curve curve = Curves.easeOutCubic;
}

/// Fixed control sizes.
///
/// Touch targets below 44 fail accessibility guidance on both platforms, so
/// [minTouchTarget] is a floor, not a preference.
abstract final class AppSize {
  static const double minTouchTarget = 44;
  static const double buttonHeightSm = 36;
  static const double buttonHeightMd = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 72;
  static const double hairline = 1;
}
