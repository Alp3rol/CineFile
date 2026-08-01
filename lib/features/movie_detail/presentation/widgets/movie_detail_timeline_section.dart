import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/database/app_database.dart';
import 'movie_detail_timeline_item.dart';

// "İzleme Geçmişim" section: loading/error/empty states plus the timeline
// list itself.
class MovieDetailTimelineSection extends StatelessWidget {
  final AsyncValue<List<WatchRecord>> watchRecordsAsync;
  // Takes the whole record, not just its int id: deleting needs the record's
  // remoteId to address the right Firestore document (see WatchRecords.remoteId).
  final Future<void> Function(WatchRecord record) onDelete;

  const MovieDetailTimelineSection({
    super.key,
    required this.watchRecordsAsync,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).timelineTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        watchRecordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text(AppLocalizations.of(context).timelineLoadFailed),
          data: (records) {
            if (records.isEmpty) {
              // AppEmptyState with no call to action: adding a record from
              // here is what the screen's sticky button already does, so a
              // second one would be a duplicate of it a few hundred pixels
              // further up.
              return AppEmptyState(
                icon: Icons.history_rounded,
                title: AppLocalizations.of(context).timelineEmpty,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, idx) {
                final record = records[idx];
                return MovieDetailTimelineItem(
                  record: record,
                  isLast: idx == records.length - 1,
                  onDelete: () => onDelete(record),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
