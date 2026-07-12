import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import 'share_compose_sheet.dart';

// Picks WHICH of the user's own collections to share — like
// share_movie_picker_sheet.dart, this only picks; it never writes anything.
// Selecting closes this sheet and opens ShareComposeSheet(type: 'collection'),
// which is what actually turns the collection's live sync on (see
// setCollectionVisibility) and creates the post.
class ShareCollectionPickerSheet extends ConsumerWidget {
  const ShareCollectionPickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ShareCollectionPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(customListsProvider);

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
            'Koleksiyon Paylaş',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            'Toplulukla paylaşmak istediğin koleksiyonu seç.',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          listsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.accentColor))),
            error: (err, _) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.redAccent))),
            data: (lists) {
              if (lists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Henüz bir koleksiyonun yok.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                );
              }

              return Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.collections_bookmark_outlined, color: AppTheme.accentColor),
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
                      trailing: list.isPublic
                          ? const Icon(Icons.public_rounded, color: AppTheme.accentColor, size: 18)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        ShareComposeSheet.show(
                          context,
                          type: 'collection',
                          collectionPayload: {
                            'listId': list.id,
                            'name': list.name,
                            'description': list.description,
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
