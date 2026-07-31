// parseWatchProviders reduces TMDb's all-countries payload to one region's
// slice. It is a free function over plain JSON precisely so these cases need
// no container, no network stub and no widget.
//
// The payloads below are trimmed from real responses (Inception / Game of
// Thrones, TR and US) so the shapes are the ones actually served.
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/features/movie_detail/domain/watch_provider_models.dart';

Map<String, dynamic> _provider(int id, String name, {int priority = 0, String? logo}) => {
      'provider_id': id,
      'provider_name': name,
      'display_priority': priority,
      'logo_path': logo ?? '/logo$id.jpg',
    };

void main() {
  group('parseWatchProviders', () {
    test('slices out the requested region and groups by category', () {
      final result = parseWatchProviders({
        'TR': {
          'link': 'https://www.themoviedb.org/movie/27205/watch?locale=TR',
          'flatrate': [_provider(8, 'Netflix')],
          'rent': [_provider(3, 'Google Play Movies'), _provider(2, 'Apple TV Store')],
          'buy': [_provider(2, 'Apple TV Store')],
        },
        'US': {
          'flatrate': [_provider(15, 'Hulu')],
        },
      }, 'TR');

      expect(result, isNotNull);
      expect(result!.region, 'TR');
      expect(result.link, contains('locale=TR'));
      expect(result.byCategory[WatchProviderCategory.flatrate]!.single.name, 'Netflix');
      expect(result.byCategory[WatchProviderCategory.rent]!.map((p) => p.name),
          containsAll(<String>['Google Play Movies', 'Apple TV Store']));
      expect(result.byCategory[WatchProviderCategory.buy]!.single.providerId, 2);
    });

    test('returns null when the region is absent', () {
      // The common case, not an error: a title carried in thirty countries is
      // missing from the other eighty.
      final result = parseWatchProviders({
        'US': {
          'flatrate': [_provider(15, 'Hulu')],
        },
      }, 'TR');

      expect(result, isNull);
    });

    test('returns null for a title with no providers anywhere', () {
      expect(parseWatchProviders(const {}, 'TR'), isNull);
    });

    test('returns null when the region exists but carries no usable category', () {
      // A widget must never be handed an object that renders as a heading with
      // nothing under it.
      final result = parseWatchProviders({
        'TR': {'link': 'https://example.invalid', 'flatrate': <dynamic>[]},
      }, 'TR');

      expect(result, isNull);
    });

    test('merges free and ads into one deduped category', () {
      // A service legitimately appears in both buckets; listing it twice under
      // the same heading looks like a bug.
      // Distinct priorities so this asserts the merge, not the tiebreak —
      // ordering has its own test below.
      final result = parseWatchProviders({
        'TR': {
          'free': [_provider(100, 'Tubi', priority: 0)],
          'ads': [_provider(100, 'Tubi', priority: 0), _provider(101, 'Pluto TV', priority: 1)],
        },
      }, 'TR');

      final free = result!.byCategory[WatchProviderCategory.free]!;
      expect(free.map((p) => p.name), ['Tubi', 'Pluto TV']);
      expect(result.byCategory.containsKey(WatchProviderCategory.flatrate), isFalse);
    });

    test('sorts by display priority, then by name for a stable order', () {
      final result = parseWatchProviders({
        'TR': {
          'flatrate': [
            _provider(3, 'Zulu', priority: 5),
            _provider(1, 'Beta', priority: 1),
            // Same priority as Beta — the name breaks the tie, so the order is
            // reproducible rather than dependent on TMDb's array order.
            _provider(2, 'Alpha', priority: 1),
          ],
        },
      }, 'TR');

      expect(
        result!.byCategory[WatchProviderCategory.flatrate]!.map((p) => p.name),
        ['Alpha', 'Beta', 'Zulu'],
      );
    });

    test('skips malformed provider entries instead of throwing', () {
      // One bad row must not take down a whole section.
      final result = parseWatchProviders({
        'TR': {
          'flatrate': [
            _provider(8, 'Netflix'),
            {'provider_name': 'No id'},
            {'provider_id': 9},
            'not a map',
            null,
          ],
        },
      }, 'TR');

      expect(result!.byCategory[WatchProviderCategory.flatrate]!.map((p) => p.name), ['Netflix']);
    });

    test('tolerates a missing link and a null logo', () {
      final result = parseWatchProviders({
        'TR': {
          'flatrate': [
            {'provider_id': 8, 'provider_name': 'Netflix', 'logo_path': null},
          ],
        },
      }, 'TR');

      expect(result!.link, isNull);
      expect(result.byCategory[WatchProviderCategory.flatrate]!.single.logoPath, isNull);
    });

    test('isEmpty is never true for a returned availability', () {
      // The widget short-circuits on `== null || isEmpty`; this pins that the
      // parser never hands back an object that is technically present but has
      // nothing to draw.
      final result = parseWatchProviders({
        'TR': {
          'buy': [_provider(2, 'Apple TV Store')],
        },
      }, 'TR');

      expect(result!.isEmpty, isFalse);
    });
  });
}
