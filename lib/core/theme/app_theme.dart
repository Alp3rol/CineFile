import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Assembles [ThemeData] from the palette in [AppColors] and the scales in
/// `app_tokens.dart`.
///
/// The rule for this file: it may *arrange* tokens, never *invent* values. A
/// literal number or colour appearing below is a defect — it means one more
/// place to edit when the identity changes.
class AppTheme {
  AppTheme._();

  // Palette forwarders.
  //
  // These predate [AppColors] and are still referenced widely, so they stay as
  // aliases while screens migrate. They are intentionally *not* marked
  // `@Deprecated` yet: that would emit a warning at every existing call site
  // and bury real findings in `flutter analyze`, which is currently clean.
  // The annotation goes on in Faz 4, once the feature code no longer uses them.
  static const Color backgroundColor = AppColors.background;
  static const Color surfaceColor = AppColors.surface;
  static const Color accentColor = AppColors.accent;
  static const Color ratingColor = AppColors.rating;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color borderColor = AppColors.border;

  /// Typography scale.
  ///
  /// Outfit carries structure (display/title), Inter carries reading text
  /// (body/label) — the split the app already used, now applied consistently.
  ///
  /// Ten distinct sizes rather than the eight originally targeted: 13px (×78)
  /// and 11px (×70) were the two most-used sizes in the whole codebase and had
  /// no role to land on, which is exactly why 440 inline `GoogleFonts` calls
  /// exist. Omitting them would have pushed those call sites straight back
  /// into inline styles.
  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.1,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // The 13px step. Dense list rows and secondary descriptions.
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        // Button and tab labels. Weight raised from the previous w300: Material
        // resolves button text from `labelLarge`, and 12px w300 was too light
        // to read as an action, which is part of why buttons were restyled
        // individually.
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        // The 11px step. Chips, badges, overline metadata.
        labelMedium: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        // Smallest step — tertiary caption under a poster (watch info,
        // director/year) that 12px reads slightly too large for.
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
      );

  /// Shared button geometry. Every button variant differs only in colour, so
  /// the shape/padding/target-size decisions are made exactly once here.
  ///
  /// Replaces 26 independent `styleFrom` call sites that had drifted to four
  /// different vertical paddings (12/14/16) and three different radii
  /// (12/14/20) for what was conceptually the same control.
  static ButtonStyle _buttonBase({
    required Color background,
    required Color foreground,
    BorderSide? side,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return background.withValues(alpha: AppOpacity.disabled);
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foreground.withValues(alpha: AppOpacity.disabled);
        }
        return foreground;
      }),
      // Ripple and hover tints derive from the foreground so every variant
      // gets feedback proportional to its own colour.
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foreground.withValues(alpha: AppOpacity.soft);
        }
        if (states.contains(WidgetState.hovered)) {
          return foreground.withValues(alpha: AppOpacity.subtle);
        }
        return null;
      }),
      side: side == null ? null : WidgetStatePropertyAll(side),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(AppColors.transparent),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(
        Size(0, AppSize.buttonHeightMd),
      ),
      // Buttons must stay tappable even when their label is short.
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      shadowColor: AppColors.shadow,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.rating,
        onSecondary: AppColors.onAccentAlt,
        error: AppColors.error,
        onError: AppColors.onAccentAlt,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceRaised,
        surfaceContainerLowest: AppColors.surfaceSunken,
        outline: AppColors.border,
        outlineVariant: AppColors.borderStrong,
        shadow: AppColors.shadow,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.headlineSmall,
      ),

      // Navigation Bar (glassmorphism base).
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            AppColors.background.withValues(alpha: AppOpacity.overlay),
        surfaceTintColor: AppColors.transparent,
        indicatorColor: AppColors.accent.withValues(alpha: AppOpacity.soft),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: AppRadius.allPill,
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelLarge!.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.accent,
              size: AppSize.iconLg,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: AppSize.iconLg,
          );
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allLg,
          side: const BorderSide(
            color: AppColors.border,
            width: AppSize.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: textTheme.labelMedium?.copyWith(color: AppColors.error),
      ),

      // ------------------------------------------------------------------
      // Button themes.
      //
      // Absent until now, which is the single biggest cause of the drift:
      // every button in the app had to fully specify itself because there was
      // nothing to inherit from.
      // ------------------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonBase(
          background: AppColors.accent,
          foreground: AppColors.onAccent,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: _buttonBase(
          background: AppColors.accent,
          foreground: AppColors.onAccent,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonBase(
          background: AppColors.transparent,
          foreground: AppColors.textPrimary,
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: AppSize.hairline,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: _buttonBase(
          background: AppColors.transparent,
          foreground: AppColors.accent,
        ).copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppSize.buttonHeightSm),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.textSecondary,
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.textPrimary.withValues(alpha: AppOpacity.soft);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.textPrimary
                  .withValues(alpha: AppOpacity.subtle);
            }
            return null;
          }),
          minimumSize: const WidgetStatePropertyAll(
            Size(AppSize.minTouchTarget, AppSize.minTouchTarget),
          ),
        ),
      ),

      // ------------------------------------------------------------------
      // Overlay surfaces. 21 `showDialog` and 20 `showModalBottomSheet` call
      // sites previously styled their own chrome for lack of these.
      // ------------------------------------------------------------------

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        barrierColor: AppColors.barrier,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allLg,
          side: const BorderSide(
            color: AppColors.border,
            width: AppSize.hairline,
          ),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: AppColors.surface,
        modalBarrierColor: AppColors.barrier,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.borderStrong,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.topXl),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.allMd,
          side: const BorderSide(
            color: AppColors.border,
            width: AppSize.hairline,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: AppOpacity.soft),
        disabledColor:
            AppColors.surface.withValues(alpha: AppOpacity.disabled),
        checkmarkColor: AppColors.accent,
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: AppColors.accent,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: AppSize.hairline,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.allPill),
        showCheckmark: false,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppSize.hairline,
        space: AppSpacing.lg,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: AppRadius.allSm,
          border: Border.all(color: AppColors.border),
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.transparent,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onAccent;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return AppColors.surfaceRaised;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.border),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.rating,
        overlayColor: AppColors.rating.withValues(alpha: AppOpacity.soft),
        valueIndicatorColor: AppColors.surfaceRaised,
        valueIndicatorTextStyle: textTheme.labelLarge,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
        ),
        trackColor: const WidgetStatePropertyAll(AppColors.transparent),
        thickness: const WidgetStatePropertyAll(4),
        radius: const Radius.circular(AppRadius.sm),
        interactive: true,
      ),
    );
  }
}

class CineFileScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Tüm otomatik scrollbar çizimlerini tamamen engelle
    return child;
  }
}
