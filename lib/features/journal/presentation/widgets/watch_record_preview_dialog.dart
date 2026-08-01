import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';

/// One "label: value" line in the preview, with an optional edit affordance.
class _PreviewDetailRow extends StatelessWidget {
  const _PreviewDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: AppSize.iconSm, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onEdit != null)
          AppPressable(
            onTap: onEdit,
            borderRadius: AppRadius.xs,
            semanticLabel: label,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: AppSize.iconSm,
              color: AppColors.accent,
            ),
          ),
      ],
    );
  }
}

/// Prompts for a new episode count. Returns null when dismissed or left blank.
Future<int?> _askEpisodeCount(BuildContext context, int current) {
  final controller = TextEditingController(text: current.toString());

  return AppDialog.show<int>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);

      return AlertDialog(
        title: Text(l10n.recordEpisodeCount),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.recordEpisodeCountHint),
        ),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          AppButton(
            label: l10n.commonSave,
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(dialogContext, val);
            },
          ),
        ],
      );
    },
    // This controller was never disposed at all before.
  ).whenComplete(controller.dispose);
}

// Quick info long-press modal preview with Ranking editing
void showWatchRecordPreviewDialog(
  BuildContext context,
  Movie movie,
  WatchRecord record,
  UserMovieSetting? setting, {
  required Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking,
  required Future<void> Function() onDelete,
  required Future<void> Function(DateTime newDate) onUpdateDate,
  required Future<void> Function(int newCount) onUpdateEpisodes,
  required Future<void> Function(bool newValue) onUpdatePrivacy,
}) {
  DateTime currentDate = record.watchDate;
  int currentEpisodeCount = record.episodeCount;
  bool currentIsPublic = record.isPublic;
  final rankController =
      TextEditingController(text: setting?.personalRanking?.toString() ?? '');

  AppDialog.show<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context);
          final textTheme = Theme.of(context).textTheme;
          final dateStr = formatShortDate(context, currentDate);

          Future<void> applyRank(int? newRank) async {
            try {
              await onUpdateRanking(
                  {(tmdbId: movie.tmdbId, isTv: movie.isTv): newRank});
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              if (context.mounted) {
                showPremiumToast(context, l10n.journalReorderFailed,
                    isError: true);
              }
            }
          }

          return Dialog(
            backgroundColor: AppColors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.xl,
              opacity: AppOpacity.overlay,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.allXs,
                        child: AppNetworkImage(
                          imageUrl: movie.posterPath != null
                              ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                              : '',
                          seed: movie.title,
                          width: 44,
                          height: 66,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title, style: textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.recordYearDirector(
                                movie.releaseYear?.toString() ??
                                    l10n.yearUnknown,
                                movie.director ?? l10n.directorMissing,
                              ),
                              style: textTheme.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.rating,
                                  size: AppSize.iconSm,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${record.rating}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  l10n.recordMood(record.mood ?? '🍿'),
                                  style: textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // Details Grid
                  _PreviewDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: l10n.journalColumnWatchDate,
                    value: dateStr,
                    onEdit: () async {
                      final newDateTime = await PremiumDatePicker.show(
                        context,
                        initialDate: currentDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (newDateTime != null) {
                        await onUpdateDate(newDateTime);
                        setState(() => currentDate = newDateTime);
                      }
                    },
                  ),
                  if (movie.isTv) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _PreviewDetailRow(
                      icon: Icons.ondemand_video_rounded,
                      label: l10n.recordEpisodesWatched,
                      value: l10n.recordEpisodesCount(currentEpisodeCount),
                      onEdit: () async {
                        final newCount = await _askEpisodeCount(
                            context, currentEpisodeCount);
                        if (newCount != null) {
                          await onUpdateEpisodes(newCount);
                          setState(() => currentEpisodeCount = newCount);
                        }
                      },
                    ),
                  ],
                  if (record.watchPlace != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _PreviewDetailRow(
                      icon: Icons.location_on_outlined,
                      label: l10n.recordWatchPlace,
                      value: record.watchPlace!,
                    ),
                  ],
                  if (record.watchCompanion != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _PreviewDetailRow(
                      icon: Icons.people_outline_rounded,
                      label: l10n.recordCompanions,
                      value: record.watchCompanion!,
                    ),
                  ],

                  // Controls ONLY the "Son İzlediklerim" section on the user's
                  // own profile — unrelated to the Community feed, which is
                  // populated by explicit posts (see share_compose_sheet.dart),
                  // not by this flag.
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.public_rounded,
                            color: AppColors.accent,
                            size: AppSize.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.addRecordVisibilityLabel,
                            style: textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Switch(
                        value: currentIsPublic,
                        onChanged: (value) async {
                          try {
                            await onUpdatePrivacy(value);
                            setState(() => currentIsPublic = value);
                          } catch (e) {
                            if (context.mounted) {
                              showPremiumToast(
                                  context, l10n.recordVisibilityFailed,
                                  isError: true);
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  // Edit Ranking Row
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.format_list_numbered_rounded,
                        color: AppColors.accent,
                        size: AppSize.iconSm,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.recordMyRank,
                        style: textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 50,
                        height: AppSize.iconLg,
                        child: TextField(
                          controller: rankController,
                          keyboardType: TextInputType.number,
                          style: textTheme.labelMedium
                              ?.copyWith(color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '-',
                            contentPadding: EdgeInsets.zero,
                            fillColor: AppColors.surfaceSunken,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.allXs,
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (val) => applyRank(
                            val.trim().isEmpty ? null : int.tryParse(val.trim()),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (setting?.personalRanking != null)
                        AppButton(
                          label: l10n.recordRemoveRank,
                          variant: AppButtonVariant.ghost,
                          size: AppButtonSize.small,
                          onPressed: () => applyRank(null),
                        ),
                    ],
                  ),

                  // Notes section
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.recordMyNotes,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: AppRadius.allSm,
                    ),
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: SingleChildScrollView(
                      child: Text(
                        record.notes != null && record.notes!.trim().isNotEmpty
                            ? record.notes!
                            : l10n.recordNoNotes,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        label: l10n.recordDelete,
                        variant: AppButtonVariant.destructive,
                        size: AppButtonSize.small,
                        onPressed: () async {
                          final confirmed = await AppDialog.confirm(
                            context: context,
                            title: l10n.recordDeleteConfirmTitle,
                            message: l10n.recordDeleteConfirmBody,
                            confirmLabel: l10n.commonDelete,
                            cancelLabel: l10n.commonCancel,
                            isDestructive: true,
                          );
                          if (confirmed != true) return;

                          try {
                            await onDelete();
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              showPremiumToast(context, l10n.recordDeleteFailed,
                                  isError: true);
                            }
                          }
                        },
                      ),
                      AppButton(
                        label: l10n.commonClose,
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    // Never disposed before: the preview could be opened and closed any number
    // of times and each one left its rank controller behind.
  ).whenComplete(rankController.dispose);
}
