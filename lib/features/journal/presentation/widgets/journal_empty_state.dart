import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../main_shell.dart';

class JournalEmptyState extends ConsumerWidget {
  final String activeFilter;
  final String searchQuery;
  final VoidCallback? onClearFilters;

  const JournalEmptyState({
    super.key,
    required this.activeFilter,
    required this.searchQuery,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFiltered = activeFilter != 'all' || searchQuery.isNotEmpty;

    return AppEmptyState(
      icon: isFiltered ? Icons.search_off_rounded : Icons.menu_book_rounded,
      title: l10n.journalEmptyTitle,
      subtitle: isFiltered
          ? l10n.journalEmptyFiltered
          : l10n.journalEmptyNoRecords,
      ctaLabel: isFiltered
          ? l10n.journalClearFiltersCTA
          : l10n.journalAddFirstRecordCTA,
      onCta: () {
        if (isFiltered) {
          onClearFilters?.call();
        } else {
          // Switch to search tab (index 1) in MainShell
          ref.read(mainShellTabIndexProvider.notifier).state = 1;
        }
      },
    );
  }
}
