import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Modal bottom sheets.
///
/// Wraps the 20 `showModalBottomSheet` call sites, each of which was passing
/// its own `backgroundColor`, `shape` and `isScrollControlled` flags. The
/// chrome now comes from `bottomSheetTheme`; this only fixes the behavioural
/// defaults that were being repeated.
abstract final class AppSheet {
  /// Shows [builder] as a modal sheet.
  ///
  /// [isScrollControlled] defaults to true because nearly every sheet in this
  /// app contains a list or a form — with it false, a sheet is capped at half
  /// the screen and its content silently overflows, which is why the existing
  /// call sites all set it by hand.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      // Keeps content clear of the home indicator and the status bar without
      // every sheet remembering to wrap itself in a SafeArea.
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        // Lifts the sheet above the keyboard when it holds a text field.
        // Omitting this is the single most common bottom-sheet bug, and
        // several sheets in this app currently have it.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: builder(sheetContext),
      ),
    );
  }
}

/// Dialogs.
abstract final class AppDialog {
  /// Shows an arbitrary dialog. Chrome comes from `dialogTheme`.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// A yes/no confirmation. Resolves to true only if the user confirmed —
  /// dismissing by tapping the barrier resolves to null, so callers should
  /// check `== true` rather than treating the result as a bare bool.
  ///
  /// [isDestructive] switches the confirm button to the destructive variant;
  /// use it for anything the user cannot undo.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required String cancelLabel,
    String? message,
    bool isDestructive = false,
  }) {
    return show<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            label: confirmLabel,
            variant: isDestructive
                ? AppButtonVariant.destructive
                : AppButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
  }
}
