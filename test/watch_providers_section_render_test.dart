// The section is deliberately silent about failure: loading, a network error,
// a region TMDb has no data for, and a title carried nowhere all render as
// nothing. That makes it impossible for a supplementary section to break the
// detail screen — and it makes these the tests that prove it, since nothing
// else would notice.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/localized_app.dart';
import 'support/network_image_mock.dart';
import 'package:cinefile/core/network/tmdb_exception.dart';
import 'package:cinefile/features/movie_detail/domain/watch_provider_models.dart';
import 'package:cinefile/features/movie_detail/presentation/watch_providers_provider.dart';
import 'package:cinefile/features/movie_detail/presentation/widgets/movie_detail_watch_providers_section.dart';

const _key = (tmdbId: 1, isTv: false);

WatchProvider _p(int id, String name) => WatchProvider(
      providerId: id,
      name: name,
      logoPath: '/l$id.jpg',
      displayPriority: 0,
    );

/// A provider TMDb has no artwork for. Built explicitly rather than by passing
/// `logo: null` to [_p] — a `logo ?? default` parameter silently substitutes
/// the default for null, so the no-logo path would never actually be exercised.
const _noLogoProvider =
    WatchProvider(providerId: 2, name: 'Apple TV', logoPath: null, displayPriority: 0);

WatchAvailability _availability(Map<WatchProviderCategory, List<WatchProvider>> byCategory) =>
    WatchAvailability(region: 'TR', link: 'https://example.invalid', byCategory: byCategory);

/// [availability] may also throw — that is how the failed-request case is set up.
Widget _wrap(Future<WatchAvailability?> Function() availability) {
  return ProviderScope(
    overrides: [
      watchProvidersProvider(_key).overrideWith((ref) => availability()),
    ],
    child: const LocalizedTestApp(
      locale: Locale('tr'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: MovieDetailWatchProvidersSection(tmdbId: 1, isTv: false),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  testWidgets('renders each non-empty category, in order, with the JustWatch credit',
      (tester) async {
    await tester.pumpWidget(_wrap(() async => _availability({
          WatchProviderCategory.flatrate: [_p(8, 'Netflix')],
          WatchProviderCategory.rent: [_p(3, 'Google Play')],
        })));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nerede İzlenir?'), findsOneWidget);
    expect(find.text('Abonelikle'), findsOneWidget);
    expect(find.text('Kirala'), findsOneWidget);
    // A category with nothing in it must not produce a bare heading.
    expect(find.text('Ücretsiz'), findsNothing);
    expect(find.text('Satın Al'), findsNothing);

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Google Play'), findsOneWidget);

    // TMDb's terms require crediting JustWatch for this data.
    expect(
      find.text('Yayın platformu bilgileri JustWatch tarafından sağlanmaktadır.'),
      findsOneWidget,
    );

    // Fixed order: cheapest to the user first.
    expect(
      tester.getTopLeft(find.text('Abonelikle')).dy,
      lessThan(tester.getTopLeft(find.text('Kirala')).dy),
    );
  });

  testWidgets('renders nothing when the title is unavailable in the region', (tester) async {
    await tester.pumpWidget(_wrap(() async => null));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nerede İzlenir?'), findsNothing);
    expect(
      tester.getSize(find.byType(MovieDetailWatchProvidersSection)),
      Size.zero,
      reason: 'an unavailable title must cost no vertical space',
    );
  });

  testWidgets('swallows a failed request without disturbing the screen', (tester) async {
    // The case that protects the CI proxy run and any real outage: a 404 from a
    // missing proxy allowlist entry reaches the widget as an exception.
    await tester.pumpWidget(_wrap(
      () async => throw const TmdbException(TmdbFailure.unknown, operation: 'watch providers'),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nerede İzlenir?'), findsNothing);
  });

  testWidgets('falls back to an initial when a provider has no logo', (tester) async {
    await tester.pumpWidget(_wrap(() async => _availability({
          WatchProviderCategory.buy: [_noLogoProvider],
        })));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Satın Al'), findsOneWidget);
    expect(find.text('Apple TV'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('shows every provider in a category', (tester) async {
    await tester.pumpWidget(_wrap(() async => _availability({
          WatchProviderCategory.flatrate: [_p(8, 'Netflix'), _p(9, 'BluTV'), _p(10, 'MUBI')],
        })));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final name in ['Netflix', 'BluTV', 'MUBI']) {
      expect(find.text(name), findsOneWidget, reason: '$name should be listed');
    }
  });
}
