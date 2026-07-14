import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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
                          color: Colors.white12,
                          width: 50,
                          height: 75,
                          child: const Icon(Icons.collections_bookmark_rounded, color: Colors.white24, size: 24),
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
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (list.description != null && list.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          list.description!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
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
                            '$totalCount Film • $watchedCount İzlenen',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '%${(progress * 100).toInt()}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: progress == 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? Colors.greenAccent : AppTheme.accentColor,
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
                Icon(Icons.public_rounded, color: AppTheme.accentColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Toplulukla paylaşılıyor',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onStopSharing,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(
                    'Paylaşımı Durdur',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
