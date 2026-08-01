import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
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
      backgroundColor: AppColors.transparent,
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
          const AppSheetHandle(),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).shareCollectionTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            AppLocalizations.of(context).shareCollectionPickPrompt,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          listsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.accent))),
            error: (err, _) => Center(child: Text(AppLocalizations.of(context).commonErrorWithDetail('$err'), style: const TextStyle(color: AppColors.error))),
            data: (lists) {
              if (lists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    AppLocalizations.of(context).shareCollectionNone,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
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
                      leading: const Icon(Icons.collections_bookmark_outlined, color: AppColors.accent),
                      title: Text(
                        list.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: list.description != null && list.description!.trim().isNotEmpty
                          ? Text(
                              list.description!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: list.isPublic
                          ? const Icon(Icons.public_rounded, color: AppColors.accent, size: 18)
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
