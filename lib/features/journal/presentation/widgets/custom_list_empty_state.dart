import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';

class CustomListEmptyState extends StatelessWidget {
  const CustomListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppEmptyState(
      icon: Icons.movie_filter_rounded,
      title: l10n.collectionEmptyTitle,
      subtitle: l10n.collectionEmptyHint,
    );
  }
}
