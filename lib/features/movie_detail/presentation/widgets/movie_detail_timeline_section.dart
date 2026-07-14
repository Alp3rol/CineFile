import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import 'movie_detail_timeline_item.dart';

// "İzleme Geçmişim" section: loading/error/empty states plus the timeline
// list itself.
class MovieDetailTimelineSection extends StatelessWidget {
  final AsyncValue<List<WatchRecord>> watchRecordsAsync;
  final Future<void> Function(int recordId) onDelete;

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
          'İzleme Geçmişim',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        watchRecordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('İzleme geçmişi hatası: $err'),
          data: (records) {
            if (records.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Bu filmi henüz izlemediniz.',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
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
                  onDelete: () => onDelete(record.id),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
