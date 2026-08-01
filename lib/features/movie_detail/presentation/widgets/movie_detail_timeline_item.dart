import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/ui.dart';
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

  static const double _markerDiameter = 32;

  /// Height of the rule joining one marker to the next. Fixed rather than
  /// measured, so it is tuned to the card height rather than derived from it.
  static const double _connectorHeight = 100;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.timelineDeleteTitle,
      message: l10n.timelineDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonDiscard,
      isDestructive: true,
    );

    if (confirmed == true) await onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final dateStr = DateFormat('dd.MM.yyyy').format(record.watchDate);

    /// Small icon + text pair used for the place and companion lines.
    Widget meta(IconData icon, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 2),
          Text(text, style: textTheme.labelMedium),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator Left Pillar
        Column(
          children: [
            // Circular badge watch order number (e.g. 1, 2)
            Container(
              width: _markerDiameter,
              height: _markerDiameter,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${record.watchNumber}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Vertical connecting line
            if (!isLast)
              Container(
                width: 2,
                height: _connectorHeight,
                color: AppColors.accent.withValues(alpha: AppOpacity.strong),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),

        // Record content card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.lg,
              useBlur: false, // per-entry card inside the rewatch-history list
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Star Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.rating,
                            size: AppSize.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${record.rating}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('/10', style: textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Place, companion, mood info
                  Row(
                    children: [
                      Text(
                        l10n.timelineMood(record.mood ?? '🍿'),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (record.watchPlace != null)
                        meta(Icons.location_on_outlined, record.watchPlace!),
                      if (record.watchCompanion != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        meta(Icons.people_alt_outlined, record.watchCompanion!),
                      ],
                    ],
                  ),

                  // Notes (if any) & delete button
                  if (record.notes != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      record.notes!,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      tooltip: l10n.commonDelete,
                      color: AppColors.error,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: AppSize.iconSm,
                      ),
                      onPressed: () => _confirmDelete(context),
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
