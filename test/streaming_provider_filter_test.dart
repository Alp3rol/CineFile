import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/features/discover/controllers/streaming_provider_controller.dart';

void main() {
  test('SelectedStreamingProvidersNotifier toggles and clears provider selections', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(selectedStreamingProvidersProvider.notifier);

    // Initial state is empty (All platforms selected)
    expect(container.read(selectedStreamingProvidersProvider), isEmpty);

    // Toggle Netflix (id: 8)
    notifier.toggleProvider(8);
    expect(container.read(selectedStreamingProvidersProvider), contains(8));

    // Toggle Prime Video (id: 119)
    notifier.toggleProvider(119);
    expect(container.read(selectedStreamingProvidersProvider), containsAll([8, 119]));

    // Untoggle Netflix
    notifier.toggleProvider(8);
    expect(container.read(selectedStreamingProvidersProvider), isNot(contains(8)));
    expect(container.read(selectedStreamingProvidersProvider), contains(119));

    // Clear all
    notifier.clearAll();
    expect(container.read(selectedStreamingProvidersProvider), isEmpty);
  });
}
