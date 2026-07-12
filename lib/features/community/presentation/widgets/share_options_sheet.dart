import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import 'share_movie_picker_sheet.dart';
import 'share_collection_picker_sheet.dart';

// Entry point for the community feed's compose bar — deliberately NOT a
// freeform text post (see roadmap discussion: an empty "what's on your
// mind" box was explicitly rejected). Offers three structured shares
// instead: a single movie/diary entry, a bulk diary snapshot, or a
// live-synced collection — never new free-text content.
class ShareOptionsSheet extends StatelessWidget {
  const ShareOptionsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ShareOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      opacity: 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ne Paylaşmak İstersin?',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _OptionRow(
            icon: Icons.movie_outlined,
            title: 'Film Paylaş',
            subtitle: 'İzlediğin tek bir film veya diziyi paylaş.',
            onTap: () {
              Navigator.pop(context);
              ShareMoviePickerSheet.show(context);
            },
          ),
          const SizedBox(height: 8),
          _OptionRow(
            icon: Icons.auto_stories_outlined,
            title: 'Günlüğünü Paylaş',
            subtitle: 'Paylaşacağın kayıtları toplu olarak seç.',
            onTap: () {
              Navigator.pop(context);
              ShareMoviePickerSheet.show(context, multiSelect: true);
            },
          ),
          const SizedBox(height: 8),
          _OptionRow(
            icon: Icons.collections_bookmark_outlined,
            title: 'Koleksiyon Paylaş',
            // Collections are only live-mirrored to Firestore from the
            // native (Drift) side today — see movie_repository.dart's
            // WebMovieRepository.setCollectionVisibility no-op.
            subtitle: kIsWeb ? 'Bu özellik web\'de henüz desteklenmiyor' : 'Koleksiyonunu canlı olarak paylaş.',
            enabled: !kIsWeb,
            onTap: () {
              Navigator.pop(context);
              ShareCollectionPickerSheet.show(context);
            },
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.accentColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
