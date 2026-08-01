import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// What the button *means*, which decides its colour.
enum AppButtonVariant {
  /// The one action the screen wants you to take. At most one per view.
  primary,

  /// A real alternative to [primary] — outlined, still clearly a button.
  secondary,

  /// Deletes, sign-out, anything the user cannot undo.
  destructive,

  /// Lowest emphasis; reads as a link until you hover it.
  ghost,
}

enum AppButtonSize { small, medium }

/// The app's button.
///
/// Replaces 26 independent `ElevatedButton.styleFrom` call sites that had
/// drifted to four vertical paddings (12/14/16), three radii (12/14/20) and
/// two different disabled alphas (0.3/0.5) for what was conceptually the same
/// control.
///
/// Geometry is *not* set here — it comes from the button themes in
/// `AppTheme.darkTheme`, so a change to button shape happens in one place and
/// reaches plain `FilledButton`s too. This widget only decides colour by
/// [variant] and handles the loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;

  /// Null disables the button. While [isLoading] is true the callback is
  /// suppressed regardless, so callers don't have to write
  /// `onPressed: loading ? null : ...` at every site — a pattern that was
  /// already being repeated and occasionally forgotten.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  bool get _enabled => onPressed != null && !isLoading;

  /// The variant's foreground colour at full strength.
  ///
  /// The button themes already encode this, but they resolve it against
  /// [WidgetState] — and a loading button is disabled, so asking the theme
  /// yields the dimmed value. The spinner needs the undimmed one: the intended
  /// loading look is a dimmed *background* with a clearly visible indicator on
  /// top, which is what the login screen did before this widget existed.
  Color get _foreground => switch (variant) {
        AppButtonVariant.primary => AppColors.onAccent,
        AppButtonVariant.secondary => AppColors.textPrimary,
        AppButtonVariant.ghost => AppColors.accent,
        AppButtonVariant.destructive => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);
    final style = _sizeOverrides();

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: _enabled ? onPressed : null,
          style: style,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: style,
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: _enabled ? onPressed : null,
          style: style,
          child: child,
        ),
      // Destructive borrows the filled shape but swaps to the error colour and
      // a tinted fill, so it reads as dangerous without shouting as loudly as
      // a solid red block.
      AppButtonVariant.destructive => FilledButton(
          onPressed: _enabled ? onPressed : null,
          style: style.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              final alpha = states.contains(WidgetState.disabled)
                  ? AppOpacity.faint
                  : AppOpacity.soft;
              return AppColors.error.withValues(alpha: alpha);
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.error.withValues(alpha: AppOpacity.disabled);
              }
              return AppColors.error;
            }),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.error, width: AppSize.hairline),
            ),
          ),
          child: child,
        ),
    };

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  static const ButtonStyle _smallGeometry = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    ),
    minimumSize: WidgetStatePropertyAll(Size(0, AppSize.buttonHeightSm)),
  );

  static const ButtonStyle _mediumGeometry = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
    ),
    minimumSize: WidgetStatePropertyAll(Size(0, AppSize.buttonHeightMd)),
  );

  ButtonStyle _sizeOverrides() {
    if (size == AppButtonSize.small) return _smallGeometry;

    // Ghost renders as a TextButton, and `textButtonTheme` deliberately uses
    // the compact geometry so that a bare `TextButton` reads as an inline
    // link (e.g. the "see all" action in AppSection). An AppButton, though, is
    // a button — a ghost one sits next to a primary one in dialog and sheet
    // action rows, and inheriting the link geometry would leave the pair
    // visibly misaligned. So restate the medium geometry explicitly here.
    if (variant == AppButtonVariant.ghost) return _mediumGeometry;

    return const ButtonStyle();
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      // Sized to the cap height of the label so swapping in the spinner does
      // not change the button's height and shift the layout around it.
      //
      // The colour is set explicitly rather than inherited: left to itself the
      // indicator picks up the global progress theme colour (the accent),
      // which would be accent-on-accent and invisible on a primary button.
      return SizedBox.square(
        dimension: AppSize.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foreground,
        ),
      );
    }

    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppSize.iconMd),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}
