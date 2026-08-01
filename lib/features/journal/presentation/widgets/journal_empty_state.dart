import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';

class JournalEmptyState extends StatelessWidget {
  final String activeFilter;
  final String searchQuery;

  const JournalEmptyState({
    super.key,
    required this.activeFilter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFiltered = activeFilter != 'all' || searchQuery.isNotEmpty;

    return AppEmptyState(
      // The icon distinguishes "you have written nothing yet" from "your
      // filter matched nothing" — the second is not really an empty state,
      // it is a search result.
      icon: activeFilter != 'all'
          ? Icons.search_off_rounded
          : Icons.menu_book_rounded,
      title: l10n.journalEmptyTitle,
      subtitle: isFiltered
          ? l10n.journalEmptyFiltered
          : l10n.journalEmptyNoRecords,
    );
  }
}
