import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinefile/features/movie_detail/presentation/widgets/movie_detail_similar_section.dart';
import 'support/localized_app.dart';
import 'support/network_image_mock.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    HttpOverrides.global = FakeImageHttpOverrides();
  });

  testWidgets('renders similar titles horizontal list with poster and rating', (tester) async {
    final movieData = {
      'id': 157336,
      'title': 'Interstellar',
      'recommendations': {
        'results': [
          {
            'id': 27205,
            'title': 'Inception',
            'poster_path': '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
            'vote_average': 8.3,
            'media_type': 'movie',
          },
          {
            'id': 693134,
            'title': 'Dune: Part Two',
            'poster_path': '/tihf8Trht9zP3scmUQfvGlAY9FU.jpg',
            'vote_average': 8.3,
            'media_type': 'movie',
          },
        ],
      },
      'similar': {
        'results': [
          {
            'id': 155,
            'title': 'The Dark Knight',
            'poster_path': '/7IPCEr7ifdH5CtU97QG7XgAAtOp.jpg',
            'vote_average': 8.5,
            'media_type': 'movie',
          },
        ],
      },
    };

    await tester.pumpWidget(
      ProviderScope(
        child: LocalizedTestApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MovieDetailSimilarSection(
                movieData: movieData,
                isTv: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Benzer Yapımlar'), findsOneWidget);
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('The Dark Knight'), findsOneWidget);
  });

  testWidgets('renders nothing when no recommendations or similar items exist', (tester) async {
    final movieData = {
      'id': 100,
      'title': 'Standalone Film',
    };

    await tester.pumpWidget(
      ProviderScope(
        child: LocalizedTestApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: MovieDetailSimilarSection(
              movieData: movieData,
              isTv: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Benzer Yapımlar'), findsNothing);
  });
}
