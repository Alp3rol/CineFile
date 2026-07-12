import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/app_database.dart';

// One card in the "İzleme Geçmişim" timeline. Deletion is delegated to the
// caller via [onDelete] rather than reaching into the parent screen's state.
class MovieDetailTimelineItem extends StatelessWidget {
  final WatchRecord record;
  final bool isLast;
  final Future<void> Function() onDelete;

  const MovieDetailTimelineItem({
    super.key,
    required this.record,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(record.watchDate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator Left Pillar
        Column(
          children: [
            // Circular badge watch order number (e.g. 1, 2)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${record.watchNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Vertical connecting line
            if (!isLast)
              Container(
                width: 2,
                height: 100, // Fixed height connecting timeline items
                color: AppTheme.accentColor.withValues(alpha: 0.5),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Record content card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      // Star Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${record.rating}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/10',
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Place, companion, mood info
                  Row(
                    children: [
                      Text(
                        'Mod: ${record.mood ?? "🍿"}',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                      ),
                      const Spacer(),

                      // Place / Companion
                      if (record.watchPlace != null) ...[
                        Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          record.watchPlace!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                      if (record.watchCompanion != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.people_alt_outlined, color: AppTheme.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          record.watchCompanion!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),

                  // Notes (if any) & delete button
                  if (record.notes != null) ...[
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 4),
                    Text(
                      record.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      onPressed: () {
                        // Confirm deletion dialog
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: AppTheme.surfaceColor,
                            title: Text('Kaydı Sil?', style: GoogleFonts.outfit(color: Colors.white)),
                            content: Text(
                              'Bu izleme kaydını günlüğünüzden kalıcı olarak silmek istediğinize emin misiniz?',
                              style: GoogleFonts.inter(color: AppTheme.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: Text('Vazgeç', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  onDelete();
                                },
                                child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
