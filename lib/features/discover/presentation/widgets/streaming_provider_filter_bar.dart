import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../controllers/streaming_provider_controller.dart';

/// Horizontal filter bar for toggling active streaming provider subscriptions.
class StreamingProviderFilterBar extends ConsumerWidget {
  const StreamingProviderFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedStreamingProvidersProvider);
    final notifier = ref.read(selectedStreamingProvidersProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: StreamingProviderItem.popularProviders.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedIds.isEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Tüm Platformlar'),
                selected: isAllSelected,
                onSelected: (_) => notifier.clearAll(),
                backgroundColor: AppTheme.surfaceColor,
                selectedColor: AppTheme.accentColor,
                labelStyle: TextStyle(
                  color: isAllSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }

          final provider = StreamingProviderItem.popularProviders[index - 1];
          final isSelected = selectedIds.contains(provider.id);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(provider.name),
              selected: isSelected,
              onSelected: (_) => notifier.toggleProvider(provider.id),
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.accentColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentColor : Colors.white12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
