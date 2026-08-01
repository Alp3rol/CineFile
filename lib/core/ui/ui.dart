/// The design system's public surface.
///
/// Feature code should import this one file rather than reaching for
/// individual primitives, so the set of things a screen is allowed to use is
/// visible in a single import line.
///
/// The tokens are re-exported here too: a screen almost never needs a
/// primitive without also needing a spacing or colour token, and splitting
/// them across three imports is what makes reaching for a raw literal feel
/// easier than doing it properly.
///
/// Distinction from `lib/core/widgets/`: this directory holds *primitives* —
/// generic, domain-free, reusable in any app. `core/widgets/` holds composites
/// that know about this app's domain (`poster_grid`, `actively_watching_row`,
/// `premium_date_picker`). A widget that mentions a movie does not belong here.
library;

export '../theme/app_colors.dart';
export '../theme/app_tokens.dart';
export 'app_avatar.dart';
export 'app_badge.dart';
export 'app_button.dart';
export 'app_card.dart';
export 'app_chip.dart';
export 'app_empty_state.dart';
export 'app_overlays.dart';
export 'app_pressable.dart';
export 'app_sheet_handle.dart';
export 'app_skeleton.dart';
