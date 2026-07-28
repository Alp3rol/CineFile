// A failed TMDb search used to render exactly like a search that matched
// nothing: the provider caught the error, cleared the results and explicitly
// set errorMessage to null. On a network where TMDb is intercepted — the very
// case this app ships a DoH resolver for — every search silently claimed
// "no results".
//
// These tests pin the failure surviving into the state, and the view saying
// something different for each reason.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinefile/core/constants/api_constants.dart';
import 'package:cinefile/core/network/tmdb_exception.dart';
import 'package:cinefile/core/network/tmdb_service.dart';
import 'package:cinefile/features/search/presentation/search_provider.dart';
import 'package:cinefile/features/search/presentation/widgets/search_results_view.dart';
import 'support/localized_app.dart';

/// Fails every request the way a blocked or unreachable TMDb does.
class _FailingInterceptor extends Interceptor {
  _FailingInterceptor(this.type, {this.statusCode});

  final DioExceptionType type;
  final int? statusCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response(requestOptions: options, statusCode: statusCode),
    ));
  }
}

TmdbService _failingService(DioExceptionType type, {int? statusCode}) {
  final dio = Dio()..interceptors.add(_FailingInterceptor(type, statusCode: statusCode));
  return TmdbService(dio, language: 'en-US');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => ApiConstants.tmdbApiKey = 'test-key');
  tearDown(() => ApiConstants.tmdbApiKey = '');

  Future<SearchState> searchAndSettle(WidgetTester tester, TmdbService service) async {
    final container = ProviderContainer(
      overrides: [tmdbServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    unawaitedSearch(container);
    // The notifier debounces by 350ms before it issues the request.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    return container.read(searchProvider);
  }

  testWidgets('an unreachable TMDb surfaces as a network failure, not "no results"', (tester) async {
    final state = await searchAndSettle(tester, _failingService(DioExceptionType.connectionError));

    expect(state.failure, TmdbFailure.network);
    expect(state.results, isEmpty);
  });

  testWidgets('a rejected key surfaces as an invalid-key failure', (tester) async {
    final state = await searchAndSettle(
      tester,
      _failingService(DioExceptionType.badResponse, statusCode: 401),
    );

    expect(state.failure, TmdbFailure.invalidApiKey);
  });

  testWidgets('the view shows a distinct message per failure, not the no-results state', (tester) async {
    Future<void> pumpWith(TmdbFailure failure) async {
      await tester.pumpWidget(
        ProviderScope(
          child: LocalizedTestApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: SearchResultsView(
                state: SearchState(
                  query: 'dune',
                  results: const [],
                  isLoading: false,
                  failure: failure,
                ),
                results: const [],
                scrollController: ScrollController(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpWith(TmdbFailure.network);
    expect(find.textContaining("Couldn't reach TMDb"), findsOneWidget);
    expect(find.text('No Results'), findsNothing);

    await pumpWith(TmdbFailure.invalidApiKey);
    expect(find.textContaining('API key'), findsOneWidget);

    await pumpWith(TmdbFailure.unknown);
    expect(find.textContaining("couldn't be completed"), findsOneWidget);
  });
}

/// Kicks off a search without awaiting it — the notifier debounces internally,
/// so the test drives time forward with `pump` instead.
void unawaitedSearch(ProviderContainer container) {
  container.read(searchProvider.notifier).search('dune');
}
