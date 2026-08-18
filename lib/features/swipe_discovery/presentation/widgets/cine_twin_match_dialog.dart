import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';

class CineTwinMatchDialog extends StatelessWidget {
  final Map<String, dynamic> item;
  final String matchedUsername;
  final VoidCallback onAddToWatchlist;

  const CineTwinMatchDialog({
    super.key,
    required this.item,
    required this.matchedUsername,
    required this.onAddToWatchlist,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> item,
    required String matchedUsername,
    required VoidCallback onAddToWatchlist,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CineTwinMatchDialog(
        item: item,
        matchedUsername: matchedUsername,
        onAddToWatchlist: onAddToWatchlist,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = (item['title'] ?? item['name'] ?? '') as String;
    final posterPath = item['poster_path'] as String?;
    final posterUrl = (posterPath != null && posterPath.isNotEmpty) ? '${ApiConstants.imagePathW500}$posterPath' : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        opacity: 0.95,
        borderRadius: 24,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.swipeMatchTitle,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.swipeMatchSubtitle(matchedUsername),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              if (posterUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AppNetworkImage(
                    imageUrl: posterUrl,
                    width: 110,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    onAddToWatchlist();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                  label: Text(
                    l10n.swipeMatchCTA,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.swipeMatchShare,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
