import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/actor_profile/presentation/actor_profile_provider.dart';
import 'package:filmdizi/features/actor_profile/presentation/actor_profile_screen.dart';

Widget _wrap(List<Override> overrides, int actorId) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: ActorProfileScreen(actorId: actorId),
    ),
  );
}

void main() {
  final mockActorDetails = {
    'id': 819,
    'name': 'Edward Norton',
    'profile_path': null,
    'birthday': '1969-08-18',
    'deathday': null,
    'place_of_birth': 'Boston, Massachusetts, USA',
    'biography': 'Edward Harrison Norton is an American actor and filmmaker.'
  };

  final mockFilmography = [
    {
      'id': 550,
      'title': 'Fight Club',
      'poster_path': null,
      'release_date': '1999-10-15',
      'media_type': 'movie',
      'popularity': 45.0
    },
    {
      'id': 100,
      'name': 'Some TV Show',
      'poster_path': null,
      'first_air_date': '2020-01-01',
      'media_type': 'tv',
      'popularity': 25.0
    }
  ];

  testWidgets('renders actor profile header details and filmography items', (tester) async {
    await tester.pumpWidget(_wrap([
      personDetailsProvider(819).overrideWith((ref) async => mockActorDetails),
      actorFilmographyProvider(819).overrideWith((ref) async => mockFilmography),
    ], 819));

    await tester.pumpAndSettle();

    expect(find.text('Edward Norton'), findsOneWidget);
    expect(find.text('Doğum: 18.08.1969'), findsOneWidget);
    expect(find.text('Boston, Massachusetts, USA'), findsOneWidget);
    expect(find.text('Edward Harrison Norton is an American actor and filmmaker.'), findsOneWidget);

    expect(find.text('Öne Çıkan Yapımları'), findsOneWidget);
    expect(find.text('Fight Club'), findsOneWidget);
    expect(find.text('Some TV Show'), findsOneWidget);
  });

  testWidgets('client-side filters narrow down the filmography correctly', (tester) async {
    await tester.pumpWidget(_wrap([
      personDetailsProvider(819).overrideWith((ref) async => mockActorDetails),
      actorFilmographyProvider(819).overrideWith((ref) async => mockFilmography),
    ], 819));

    await tester.pumpAndSettle();

    // Default: 'Hepsi' is selected, both movie and TV show are visible
    expect(find.text('Fight Club'), findsOneWidget);
    expect(find.text('Some TV Show'), findsOneWidget);

    // Tap 'Film' chip
    await tester.tap(find.text('Film'));
    await tester.pumpAndSettle();

    expect(find.text('Fight Club'), findsOneWidget);
    expect(find.text('Some TV Show'), findsNothing);

    // Tap 'Dizi' chip
    await tester.tap(find.text('Dizi'));
    await tester.pumpAndSettle();

    expect(find.text('Fight Club'), findsNothing);
    expect(find.text('Some TV Show'), findsOneWidget);
  });

  testWidgets('shows error state when actor details fail to load', (tester) async {
    await tester.pumpWidget(_wrap([
      personDetailsProvider(819).overrideWith((ref) async => throw Exception('Ağ hatası')),
      actorFilmographyProvider(819).overrideWith((ref) async => mockFilmography),
    ], 819));

    await tester.pumpAndSettle();

    expect(find.textContaining('Oyuncu bilgileri yüklenemedi: Exception: Ağ hatası'), findsOneWidget);
  });
}
