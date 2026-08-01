import 'package:flutter/material.dart';

/// The palette: the single place a colour is allowed to be defined.
///
/// **This file is the swap point for the visual identity work.** Every value
/// below is currently seeded with the app's existing colours so that adding
/// this layer changes nothing on screen. When the new identity is decided,
/// only the constants in this file change — no screen, no widget, no theme
/// entry should need touching. If a palette change ever requires editing a
/// second file, that is a bug in the migration, not in the palette.
///
/// The names are semantic (what the colour is *for*) rather than descriptive
/// (what it *looks like*). `accent` survives a change from red to blue;
/// `cinematicRed` would not.
abstract final class AppColors {
  // ---------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------

  /// The app background, behind everything.
  static const Color background = Color(0xFF0B0D13);

  /// Cards, sheets, inputs — anything sitting one step above [background].
  static const Color surface = Color(0xFF181B24);

  /// One step above [surface], for a surface nested inside another surface
  /// (a tile inside a card, a selected row). Previously improvised per screen
  /// with `surface.withValues(alpha:)` or an unnamed hex.
  static const Color surfaceRaised = Color(0xFF1F2330);

  /// Below [background] — wells, track backgrounds, inset areas.
  static const Color surfaceSunken = Color(0xFF06070B);

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------

  /// Primary action colour and the app's identity colour.
  static const Color accent = Color(0xFFE8362E);

  /// Tinted accent for backplates and selection fills, so call sites stop
  /// improvising their own alpha over [accent]. Consolidates the unnamed
  /// second red (`0xFFFA584F`) that had drifted into the codebase.
  static const Color accentSubtle = Color(0xFFFA584F);

  /// Ratings and scores. Consolidates three near-identical golds that were in
  /// use: this one, `0xFFFFC107` (×9) and `0xFFFFD700`.
  static const Color rating = Color(0xFFE8C468);

  // ---------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------

  /// Primary reading colour. The 538 raw `Colors.white` call sites migrate
  /// here — except where white is deliberately fixed because it sits on top of
  /// poster artwork rather than on a themed surface. Those keep [onImage].
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Supporting copy, labels, inactive tabs.
  static const Color textSecondary = Color(0xFF9BA3B4);

  /// Third-level captions — timestamps, metadata under a poster. Previously
  /// unavailable, so those call sites reused [textSecondary] at a reduced
  /// alpha, which is why 34 distinct alphas accumulated.
  static const Color textTertiary = Color(0xFF6B7385);

  /// Text and icons on top of [accent].
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Text and icons on top of [rating] — gold needs dark content to stay
  /// legible.
  static const Color onAccentAlt = Color(0xFF0B0D13);

  /// Content laid directly over artwork, where the backdrop is unknown and the
  /// colour must not follow the theme. Pair with a scrim for contrast.
  static const Color onImage = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Lines
  // ---------------------------------------------------------------------

  /// Faint white hairline (~6%), baked in so call sites use it directly
  /// instead of stacking another alpha on top.
  static const Color border = Color(0x0FFFFFFF);

  /// A visible border, for focus rings and emphasised separation.
  static const Color borderStrong = Color(0x29FFFFFF);

  // ---------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------
  // Seeded from the Material accent colours the code was already reaching for
  // directly: redAccent (×37), greenAccent (×17), amberAccent (×13).

  static const Color success = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // ---------------------------------------------------------------------
  // Overlays
  // ---------------------------------------------------------------------

  /// Scrim over imagery, and the shadow colour passed to [AppElevation].
  static const Color shadow = Color(0xFF000000);

  /// Barrier behind modals and dialogs.
  static const Color barrier = Color(0x99000000);

  /// Fully transparent. Named so `Colors.transparent` (×80) has somewhere to
  /// go and the audit script can forbid raw `Colors.` in feature code.
  static const Color transparent = Color(0x00000000);
}

/// Third-party brand colours.
///
/// Separated from [AppColors] because these are *not ours to restyle* — they
/// stay fixed when the identity changes. Previously duplicated verbatim in
/// `movie_detail_header_row.dart` and `home_recommendations_list.dart`.
abstract final class BrandColors {
  static const Color tmdbNavy = Color(0xFF0D253F);
  static const Color tmdbGreen = Color(0xFF90CEA1);
}
