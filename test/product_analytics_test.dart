import 'package:cinefile/core/analytics/product_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingClient implements AnalyticsClient {
  final collectionStates = <bool>[];
  final events = <String>[];

  @override
  Future<void> logEvent(String name) async => events.add(name);

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionStates.add(enabled);
  }
}

class _MemoryConsentStore implements AnalyticsConsentStore {
  _MemoryConsentStore([this.value]);
  bool? value;

  @override
  Future<bool?> read() async => value;

  @override
  Future<void> write(bool enabled) async => value = enabled;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('collection and events stay off without explicit consent', () async {
    final client = _RecordingClient();
    final analytics = ProductAnalytics(
      client: client,
      consentStore: _MemoryConsentStore(),
      production: true,
    );

    expect(await analytics.initialize(), isFalse);
    await analytics.log(ProductEvent.onboardingCompleted);

    expect(client.collectionStates, [false]);
    expect(client.events, isEmpty);
  });

  test(
    'consent persists and only allowlisted event names can be sent',
    () async {
      final client = _RecordingClient();
      final consentStore = _MemoryConsentStore();
      final analytics = ProductAnalytics(
        client: client,
        consentStore: consentStore,
        production: true,
      );

      await analytics.initialize();
      await analytics.setConsent(true);
      await analytics.log(ProductEvent.firstWatchRecorded);

      expect(consentStore.value, isTrue);
      expect(client.collectionStates, [false, true]);
      expect(client.events, ['first_watch_recorded']);
      expect(ProductEvent.values.map((event) => event.eventName).toSet(), {
        'onboarding_completed',
        'first_watch_recorded',
        'search_result_opened',
        'detail_watch_recorded',
        'first_collection_created',
        'wrapped_viewed',
        'wrapped_shared',
        'letterboxd_import_completed',
        'evening_picker_completed',
        'evening_feedback_saved',
      });
    },
  );

  test('debug and test builds never enable production collection', () async {
    final client = _RecordingClient();
    final analytics = ProductAnalytics(
      client: client,
      consentStore: _MemoryConsentStore(true),
      production: false,
    );

    expect(await analytics.initialize(), isTrue);
    await analytics.log(ProductEvent.wrappedViewed);

    expect(client.collectionStates, [false]);
    expect(client.events, isEmpty);
  });
}
