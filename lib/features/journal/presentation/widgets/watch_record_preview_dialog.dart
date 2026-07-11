import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../../core/widgets/premium_toast.dart';

Widget _buildPreviewDetailRow(IconData icon, String label, String value, {VoidCallback? onEdit}) {
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
      if (onEdit != null)
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Icon(Icons.edit_rounded, size: 14, color: AppTheme.accentColor),
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
  required Future<void> Function() onDelete,
  required Future<void> Function(DateTime newDate) onUpdateDate,
  required Future<void> Function(int newCount) onUpdateEpisodes,
}) {
  DateTime currentDate = record.watchDate;
  int currentEpisodeCount = record.episodeCount;
  final rankController = TextEditingController(text: setting?.personalRanking?.toString() ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final dateStr = DateFormat('dd.MM.yyyy').format(currentDate);

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
              _buildPreviewDetailRow(
                Icons.calendar_today_rounded, 
                'İzleme Tarihi', 
                dateStr,
                onEdit: () async {
                  final pickedDate = await PremiumDatePicker.show(
                    context,
                    initialDate: currentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      currentDate.hour,
                      currentDate.minute,
                    );
                    await onUpdateDate(newDateTime);
                    setState(() {
                      currentDate = newDateTime;
                    });
                  }
                },
              ),
              if (movie.isTv) ...[
                const SizedBox(height: 10),
                _buildPreviewDetailRow(
                  Icons.ondemand_video_rounded,
                  'İzlenen Bölüm Sayısı',
                  '$currentEpisodeCount Bölüm',
                  onEdit: () async {
                    final ctrl = TextEditingController(text: currentEpisodeCount.toString());
                    final newCount = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.backgroundColor,
                        title: Text('Bölüm Sayısı', style: GoogleFonts.outfit(color: Colors.white)),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Kaç bölüm izlendi?',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () {
                              final val = int.tryParse(ctrl.text);
                              if (val != null && val > 0) {
                                Navigator.pop(context, val);
                              }
                            },
                            child: const Text('Kaydet', style: TextStyle(color: AppTheme.accentColor)),
                          ),
                        ],
                      ),
                    );
                    if (newCount != null) {
                      await onUpdateEpisodes(newCount);
                      setState(() {
                        currentEpisodeCount = newCount;
                      });
                    }
                  },
                ),
              ],
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
                        try {
                          await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): newRank});
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, 'Sıralama kaydedilemedi: $e', isError: true);
                          }
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  if (setting?.personalRanking != null)
                     TextButton(
                      onPressed: () async {
                        try {
                          await onUpdateRanking({(tmdbId: movie.tmdbId, isTv: movie.isTv): null});
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, 'Sıralama kaydedilemedi: $e', isError: true);
                          }
                        }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.backgroundColor,
                          title: Text('Emin misiniz?', style: GoogleFonts.outfit(color: Colors.white)),
                          content: const Text('Bu izleme kaydı silinecek.', style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await onDelete();
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            showPremiumToast(context, 'Silme başarısız: $e', isError: true);
                          }
                        }
                      }
                    },
                    child: Text(
                      'Kaydı Sil',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton(
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
                ],
              ),
            ],
          ),
        ),
      );
        },
      );
    },
  );
}
