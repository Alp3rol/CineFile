import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Privacy-safe product events. Event payloads deliberately contain no title,
/// TMDb id, note, review, search query, user id, or other free-form value.
enum ProductEvent {
  onboardingCompleted('onboarding_completed'),
  firstWatchRecorded('first_watch_recorded'),
  searchResultOpened('search_result_opened'),
  detailWatchRecorded('detail_watch_recorded'),
  firstCollectionCreated('first_collection_created'),
  wrappedViewed('wrapped_viewed'),
  wrappedShared('wrapped_shared');

  const ProductEvent(this.eventName);
  final String eventName;
}

abstract interface class AnalyticsClient {
  Future<void> setCollectionEnabled(bool enabled);
  Future<void> logEvent(String name);
}

class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient([FirebaseAnalytics? analytics])
    : _providedAnalytics = analytics;

  final FirebaseAnalytics? _providedAnalytics;
  FirebaseAnalytics get _analytics =>
      _providedAnalytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> logEvent(String name) => _analytics.logEvent(name: name);
}

abstract interface class AnalyticsConsentStore {
  Future<bool?> read();
  Future<void> write(bool enabled);
}

class SharedPreferencesAnalyticsConsentStore implements AnalyticsConsentStore {
  static const key = 'product_analytics_enabled';

  @override
  Future<bool?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  @override
  Future<void> write(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, enabled);
  }
}

/// Owns analytics consent. Collection is opt-in and remains disabled until the
/// user explicitly enables it in Privacy Center.
class ProductAnalytics {
  ProductAnalytics({
    required AnalyticsClient client,
    required AnalyticsConsentStore consentStore,
    bool production = kReleaseMode,
  }) : this._(client, consentStore, production);

  ProductAnalytics._(this._client, this._consentStore, this._production);

  static const consentKey = SharedPreferencesAnalyticsConsentStore.key;

  final AnalyticsClient _client;
  final AnalyticsConsentStore _consentStore;
  final bool _production;
  bool _enabled = false;

  bool get enabled => _enabled;

  Future<bool> initialize() async {
    final consent = await _consentStore.read() ?? false;
    // Debug/test runs must never contaminate production metrics.
    _enabled = consent && _production;
    await _client.setCollectionEnabled(_enabled);
    return consent;
  }

  Future<void> setConsent(bool enabled) async {
    await _consentStore.write(enabled);
    _enabled = enabled && _production;
    await _client.setCollectionEnabled(_enabled);
  }

  Future<void> log(ProductEvent event) async {
    if (!_enabled) return;
    await _client.logEvent(event.eventName);
  }
}
