import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

Widget _buildPreviewDetailRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 14, color: AppTheme.textSecondary),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// Quick info long-press modal preview with Ranking editing
void showWatchRecordPreviewDialog(
  BuildContext context,
  Movie movie,
  WatchRecord record,
  UserMovieSetting? setting, {
  required Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking,
}) {
  final dateStr = DateFormat('dd.MM.yyyy').format(record.watchDate);
  final timeStr = DateFormat('HH:mm').format(record.watchDate);
  final rankController = TextEditingController(text: setting?.personalRanking?.toString() ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          opacity: 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath != null
                          ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                          : '',
                      width: 44,
                      height: 66,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${movie.releaseYear ?? "Bilinmeyen Yıl"} • ${movie.director ?? "Yönetmen Bilinmiyor"}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${record.rating}',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Ruh Hali: ${record.mood ?? "🍿"}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // Details Grid
              _buildPreviewDetailRow(Icons.calendar_today_rounded, 'Tarih & Saat', '$dateStr - $timeStr'),
              if (record.watchPlace != null) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(Icons.location_on_outlined, 'İzleme Mekanı', record.watchPlace!),
              ],
              if (record.watchCompanion != null) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(Icons.people_outline_rounded, 'Eşlik Edenler', record.watchCompanion!),
              ],

              // Edit Ranking Row
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded, color: AppTheme.accentColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Favori Sıram: ',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    height: 24,
                    child: TextField(
                      controller: rankController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '-',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.black38,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) async {
                        final newRank = val.trim().isEmpty ? null : int.tryParse(val.trim());
                        await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): newRank});
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  if (setting?.personalRanking != null)
                     TextButton(
                      onPressed: () async {
                        await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): null});
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text(
                        'Sıradan Çıkar',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),

              // Notes section
              const SizedBox(height: 16),
              Text(
                'Kişisel Notlarım:',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    record.notes != null && record.notes!.trim().isNotEmpty
                        ? record.notes!
                        : 'Kayıt eklenirken not yazılmamış.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kapat',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
