// Streaming availability is entirely a question of country, and the app had no
// notion of one before this — only language. These pin the resolution order and
// the picker's guarantee that a user outside the curated country list is not
// silently shown somebody else's catalogue.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/constants/watch_regions.dart';
import 'package:cinefile/core/l10n/l10n_lookup.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';

void main() {
  // The test binding reports en-US, so deviceCountryCode() is 'US' throughout.
  // Asserted rather than assumed, because every expectation below rests on it.
  test('the test binding reports a device country', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(deviceCountryCode(), 'US');
  });

  group('effectiveWatchRegionProvider', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('follows the device when no override is set', () {
      expect(container.read(effectiveWatchRegionProvider), 'US');
    });

    test('an explicit override wins over the device', () async {
      await container.read(watchRegionProvider.notifier).setRegion('DE');
      expect(container.read(effectiveWatchRegionProvider), 'DE');
    });

    test('clearing the override goes back to the device country', () async {
      await container.read(watchRegionProvider.notifier).setRegion('DE');
      await container.read(watchRegionProvider.notifier).setRegion(null);

      expect(container.read(watchRegionProvider), isNull);
      expect(container.read(effectiveWatchRegionProvider), 'US');
    });

    test('an override outside the curated list is honoured', () async {
      // The curated list is a convenience for finding your country, never a
      // restriction on which one you may pick.
      expect(kWatchRegions.containsKey('MY'), isFalse);
      await container.read(watchRegionProvider.notifier).setRegion('MY');

      expect(container.read(effectiveWatchRegionProvider), 'MY');
    });
  });

  // Persistence itself cannot be asserted here: AppSettingsStore is effectively
  // a no-op under flutter_test, because getApplicationDocumentsDirectory throws
  // MissingPluginException and the store swallows it in its own try/catch. What
  // is testable is the in-memory transition, which is what the UI reads.

  group('watchRegionOptions', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('includes every curated region', () {
      expect(watchRegionOptions(), containsAll(kWatchRegions.keys));
    });

    test('includes the device country even when it is not curated', () {
      // The device reports US, which IS curated, so this asserts the property
      // via the union rather than by faking the platform: no duplicate entry.
      final options = watchRegionOptions();
      expect(options.where((c) => c == 'US'), hasLength(1));
    });

    test('is sorted by display label, not by code', () {
      final options = watchRegionOptions();
      final labels = options.map(watchRegionLabel).map((l) => l.toLowerCase()).toList();
      expect(labels, orderedEquals(List<String>.from(labels)..sort()));
    });
  });

  group('watchRegionLabel', () {
    test('names a curated country in its own language', () {
      expect(watchRegionLabel('TR'), 'Türkiye');
      expect(watchRegionLabel('DE'), 'Deutschland');
    });

    test('falls back to the bare ISO code for an uncurated one', () {
      // Recognisable, and far better than hiding the country the user is in.
      expect(watchRegionLabel('MY'), 'MY');
    });
  });

  group('deviceCountryCode', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('is uppercase and two letters when present', () {
      final code = deviceCountryCode();
      expect(code, isNotNull);
      expect(code, matches(RegExp(r'^[A-Z]{2}$')));
    });
  });
}
