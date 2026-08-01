import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';

/// Label above a field in the add-watch-record sheet.
///
/// This exact style — Inter 14, semibold, primary text — was written out
/// seven times across the sheet's widgets: once each for the mood picker, the
/// rating slider, the visibility toggle, and the place, companion, notes and
/// tags fields. Seven copies is seven chances for one of them to drift.
class WatchFormLabel extends StatelessWidget {
  const WatchFormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
