import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/poster_grid.dart';
import '../actor_profile_provider.dart';

class ActorFilmographyGrid extends ConsumerWidget {
  final List<Map<String, dynamic>> filmography;

  const ActorFilmographyGrid({super.key, required this.filmography});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaFilter = ref.watch(actorMediaFilterProvider);

    final filtered = switch (mediaFilter) {
      ActorMediaFilter.all => filmography,
      ActorMediaFilter.movie => filmography.where((item) => item['media_type'] != 'tv').toList(),
      ActorMediaFilter.tv => filmography.where((item) => item['media_type'] == 'tv').toList(),
    };

    return Column(
      children: [
        // Media Filter Chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chipPadded(_chip(
                label: 'Hepsi',
                isSelected: mediaFilter == ActorMediaFilter.all,
                onSelected: (selected) {
                  if (selected) ref.read(actorMediaFilterProvider.notifier).state = ActorMediaFilter.all;
                },
              )),
              _chipPadded(_chip(
                label: 'Film',
                isSelected: mediaFilter == ActorMediaFilter.movie,
                onSelected: (selected) {
                  if (selected) ref.read(actorMediaFilterProvider.notifier).state = ActorMediaFilter.movie;
                },
              )),
              _chipPadded(_chip(
                label: 'Dizi',
                isSelected: mediaFilter == ActorMediaFilter.tv,
                onSelected: (selected) {
                  if (selected) ref.read(actorMediaFilterProvider.notifier).state = ActorMediaFilter.tv;
                },
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Öne Çıkan Yapımları',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Filmography List Grid
        Expanded(
          child: filtered.isEmpty
              ? _buildFilteredEmptyState(mediaFilter)
              : PosterGrid(
                  items: filtered,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 40),
                ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.accentColor,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderColor),
      ),
    );
  }

  Widget _chipPadded(Widget chip) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: chip);
  }

  Widget _buildFilteredEmptyState(ActorMediaFilter filter) {
    final label = filter == ActorMediaFilter.movie ? 'film' : 'dizi';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kategoride öne çıkan $label bulunamadı',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
