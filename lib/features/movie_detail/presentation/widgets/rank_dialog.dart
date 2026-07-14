import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/movie_repository.dart';

// Dialog to set/clear a movie's personal favorite ranking. Takes tmdbId/isTv
// explicitly rather than reaching into MovieDetailScreen's State, so it can
// be reused/tested independently of that widget.
void showRankDialog(
  BuildContext context,
  WidgetRef ref, {
  required int tmdbId,
  required bool isTv,
  required Map<String, dynamic> movieData,
  required UserMovieSetting? settings,
}) {
  final controller = TextEditingController(text: settings?.personalRanking?.toString() ?? '');
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Favori Sırası Belirle',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bu film için favori sıralama numarasını girin (Örn: 1, 2, 5). Boş bırakırsanız sıralamadan çıkarılır.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sıra Numarası',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) async {
                final newRank = val.trim().isEmpty ? null : int.tryParse(val.trim());
                try {
                  await _updateRank(ref, tmdbId: tmdbId, isTv: isTv, movieData: movieData, settings: settings, rank: newRank);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sıra kaydedilemedi: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            onPressed: () async {
              final input = controller.text.trim();
              final int? newRank = input.isEmpty ? null : int.tryParse(input);

              try {
                await _updateRank(ref, tmdbId: tmdbId, isTv: isTv, movieData: movieData, settings: settings, rank: newRank);
                if (context.mounted) {
                  controller.dispose();
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sıra kaydedilemedi: $e')),
                  );
                }
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  ).then((_) => controller.dispose());
}

Future<void> _updateRank(
  WidgetRef ref, {
  required int tmdbId,
  required bool isTv,
  required Map<String, dynamic> movieData,
  required UserMovieSetting? settings,
  required int? rank,
}) {
  return ref.read(movieRepositoryProvider).updatePersonalRankingLocal(
        tmdbId: tmdbId,
        isTv: isTv,
        movieData: movieData,
        settings: settings,
        rank: rank,
      );
}
