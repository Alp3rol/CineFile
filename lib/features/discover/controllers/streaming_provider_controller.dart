import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

@immutable
class StreamingProviderItem {
  const StreamingProviderItem({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  final int id;
  final String name;
  final String logoPath;

  static const List<StreamingProviderItem> popularProviders = [
    StreamingProviderItem(
      id: 8,
      name: 'Netflix',
      logoPath: '/pbpMk2JmcoNnQwx5JGp8jWBDEXv.jpg',
    ),
    StreamingProviderItem(
      id: 119,
      name: 'Prime Video',
      logoPath: '/dQeA87Bd9CeoV2m8zeoGe7yYm9v.jpg',
    ),
    StreamingProviderItem(
      id: 337,
      name: 'Disney+',
      logoPath: '/97yvRB8vBxZ1Q9_892y.jpg',
    ),
    StreamingProviderItem(
      id: 341,
      name: 'BluTV',
      logoPath: '/blutv.jpg',
    ),
    StreamingProviderItem(
      id: 11,
      name: 'MUBI',
      logoPath: '/b484l23871.jpg',
    ),
    StreamingProviderItem(
      id: 350,
      name: 'Apple TV+',
      logoPath: '/6uhKB222384.jpg',
    ),
  ];
}

final selectedStreamingProvidersProvider =
    StateProvider<Set<int>>((ref) => <int>{});

extension StreamingProviderControllerX on StateController<Set<int>> {
  void toggleProvider(int providerId) {
    if (state.contains(providerId)) {
      state = Set<int>.from(state)..remove(providerId);
    } else {
      state = Set<int>.from(state)..add(providerId);
    }
  }

  void clearAll() {
    state = <int>{};
  }
}
