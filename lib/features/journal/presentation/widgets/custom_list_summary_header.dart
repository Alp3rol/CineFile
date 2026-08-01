import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';

// Cover thumbnail + progress bar card, plus the "shared with community"
// status row when the collection is currently public.
class CustomListSummaryHeader extends StatelessWidget {
  final CustomList list;
  final String? coverPath;
  final int totalCount;
  final int watchedCount;
  final double progress;
  final bool isPublic;
  final VoidCallback onStopSharing;

  const CustomListSummaryHeader({
    super.key,
    required this.list,
    required this.coverPath,
    required this.totalCount,
    required this.watchedCount,
    required this.progress,
    required this.isPublic,
    required this.onStopSharing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GlassContainer(
            borderRadius: 16,
            opacity: 0.5,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Mini Cover Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverPath != null
                      ? AppNetworkImage(
                          imageUrl: '${ApiConstants.imagePathW185}$coverPath',
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.border,
                          width: 50,
                          height: 75,
                          child: const Icon(Icons.collections_bookmark_rounded, color: AppColors.textTertiary, size: 24),
                        ),
                ),
                const SizedBox(width: 16),

                // Info and Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                      ),
                      if (list.description != null && list.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          list.description!,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Progress indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).collectionTotalWatched(totalCount, watchedCount),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '%${(progress * 100).toInt()}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: progress == 1.0 ? AppColors.success : AppColors.accent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? AppColors.success : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Community share status — starting a share only happens via the
        // compose bar's "Koleksiyon Paylaş" flow (share_compose_sheet.dart);
        // this is stop-only, so there's no "isPublic" ambiguity about who
        // initiates the first Firestore write.
        if (isPublic)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.public_rounded, color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).collectionShared,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // The one styleFrom left in this feature, and deliberate: this
                // is an underlined link sitting inline at the end of a status
                // row, so it has to collapse to text height. AppButton's ghost
                // variant is a button — it keeps the 36px minimum that would
                // push this row taller than the line it belongs to.
                TextButton(
                  onPressed: onStopSharing,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).collectionStopSharing,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
