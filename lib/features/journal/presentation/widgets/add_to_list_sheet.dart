import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

class AddToListSheet extends ConsumerWidget {
  final Movie movieData;
  const AddToListSheet({super.key, required this.movieData});

  // Entry point to show this sheet
  static void show(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddToListSheet(movieData: movie),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(customListsProvider);
    final selectedListsAsync =
        ref.watch(listsForMovieProvider((tmdbId: movieData.tmdbId, isTv: movieData.isTv)));

    return GlassContainer(
      borderRadius: 24,
      opacity: 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Drag bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Add new list button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koleksiyona Ekle',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movieData.title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16, color: AppTheme.accentColor),
                label: Text(
                  'Yeni Liste',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                ),
                onPressed: () => _showCreateListDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // Lists items Grid/ListView
          listsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (err, _) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
            data: (lists) {
              if (lists.isEmpty) {
                return _buildEmptyState(context, ref);
              }

              final selectedListIds = selectedListsAsync.value ?? {};

              return Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final isAdded = selectedListIds.contains(list.id);

                    return CheckboxListTile(
                      activeColor: AppTheme.accentColor,
                      checkColor: Colors.black,
                      title: Text(
                        list.name,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: list.description != null && list.description!.trim().isNotEmpty
                          ? Text(
                              list.description!,
                              style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      value: isAdded,
                      onChanged: (bool? selected) async {
                        try {
                          if (selected == true) {
                            await addMovieToCustomList(ref, list.id, movieData);
                          } else {
                            await removeMovieFromCustomList(ref, list.id, movieData.tmdbId, movieData.isTv);
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Liste güncellenemedi, tekrar deneyin.')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tamam',
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
    );
  }

  // Create List Modal Dialog
  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Yeni Koleksiyon Oluştur',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Koleksiyon Adı',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Açıklama (İsteğe Bağlı)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await createCustomList(ref, name, descController.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Oluştur', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              'Hiç koleksiyonunuz yok.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Eklemek için sağ üstteki "+ Yeni Liste" butonuna basın.',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
