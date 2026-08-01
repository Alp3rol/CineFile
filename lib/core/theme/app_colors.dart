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

  /// Deep indigo card ground. Not a step on the neutral surface ramp — it is a
  /// distinct, saturated panel colour used where a card should feel like its
  /// own object rather than a shade of the background (the detail screen's
  /// info cards, the achievement grid, the profile header).
  static const Color surfaceIndigo = Color(0xFF1E1B4B);

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

  /// A warm second accent, drawn as a gradient, for the "log this to your
  /// diary" actions on the movie detail screen — its primary call to action
  /// and its primary quick action.
  ///
  /// This is a real second identity colour rather than drift: those actions
  /// are deliberately gold rather than brand red, tying them to the rating
  /// vocabulary. It is named here because it had none, so its two stops were
  /// written out as raw hex at every use.
  static const Color accentWarmStart = Color(0xFFFFB800);
  static const Color accentWarmEnd = Color(0xFFFF8C00);

  /// Content on top of the warm accent. It is a light gold, so its content has
  /// to be dark to stay legible.
  static const Color onAccentWarm = Color(0xFF0B0D13);

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

  /// Streaming services, for the little platform markers on journal entries.
  ///
  /// These were approximated with `Colors.red` / `Colors.blue` /
  /// `Colors.purpleAccent`, which are not any of these brands' actual colours —
  /// close enough to read as "some red badge", not close enough to read as
  /// Netflix. Their real values are used here for the same reason the TMDb
  /// pair is: they identify someone else, so they do not follow our palette.
  static const Color netflixRed = Color(0xFFE50914);
  static const Color primeBlue = Color(0xFF00A8E1);
  static const Color disneyBlue = Color(0xFF113CCF);

  /// Light plate placed behind a third-party logo.
  ///
  /// Many streaming-provider logos are dark artwork on a transparent
  /// background; dropped straight onto this app's dark surfaces, several major
  /// services render as an invisible smudge. Belongs here rather than with the
  /// app's own surfaces: it exists to serve other people's artwork, so it must
  /// stay light even if the app's theme stops being dark.
  static const Color logoPlate = Color(0xFFF3F3F5);
}
