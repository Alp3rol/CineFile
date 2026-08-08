import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../main_shell.dart';

class CustomListEmptyState extends ConsumerWidget {
  const CustomListEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppEmptyState(
      icon: Icons.movie_filter_rounded,
      title: l10n.collectionEmptyTitle,
      subtitle: l10n.collectionEmptyHint,
      ctaLabel: l10n.collectionAddMoviesCTA,
      onCta: () {
        // Pop the empty custom list screen and navigate to Search tab
        Navigator.of(context).pop();
        ref.read(mainShellTabIndexProvider.notifier).state = 1;
      },
    );
  }
}
