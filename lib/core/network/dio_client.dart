import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../constants/api_constants.dart';
import 'doh_resolver.dart';

final cacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnErrorExcept: [401, 403],
  maxStale: const Duration(days: 1),
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);

class DioClient {
  final Dio _dio;

  DioClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiConstants.baseUrl,
            // Previously 1.5s connect / 3s receive, chosen to fail over to the
            // alternate TMDb domain quickly. That is far inside the normal
            // range for a mobile connection: on a weak 4G or a busy hotel
            // Wi-Fi it turned working requests into "arama başarısız", and the
            // failover it was rushing towards cannot help with plain slowness
            // (the second domain is no faster). The failover still triggers on
            // an actual connection error, which arrives long before these.
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(FailoverInterceptor(_dio));
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    // Debug builds only. TMDb takes the API key as a *query parameter*, so
    // every logged request URI contains the key in plain text — which ended up
    // in release console output and in CI test logs. `kDebugMode` keeps the
    // diagnostics where they're useful without shipping the secret.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ));
    }

    // Some routers/ISPs hijack plain DNS for specific domains (observed:
    // api.themoviedb.org resolving to 127.0.0.1). Web builds can't override
    // socket-level DNS (the browser owns networking), so this only applies
    // to native platforms.
    if (!kIsWeb && _dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.connectionFactory = (uri, proxyHost, proxyPort) async {
          try {
            final socket = await Socket.connect(uri.host, uri.port, timeout: const Duration(seconds: 2));
            if (!socket.remoteAddress.isLoopback) {
              return ConnectionTask.fromSocket(Future.value(socket), socket.destroy);
            }
            // The OS resolver sent us to a sinkholed loopback address: the
            // hostname is being blocked at the DNS level. Discard this dead
            // socket and try again via DNS-over-HTTPS instead.
            socket.destroy();
          } catch (e) {
            debugPrint('DioClient: direct connect to ${uri.host} failed, trying DoH: $e');
          }

          final resolved = await DohResolver.resolve(uri.host);
          if (resolved == null) {
            throw SocketException('DNS blocked and DoH resolution failed for ${uri.host}');
          }
          final socket = await Socket.connect(resolved, uri.port, timeout: const Duration(seconds: 4));
          return ConnectionTask.fromSocket(Future.value(socket), socket.destroy);
        };
        return client;
      };
    }
  }

  Dio get dio => _dio;
}

class FailoverInterceptor extends Interceptor {
  FailoverInterceptor(this._dio);

  /// The client the failed request came from, so the retry keeps its
  /// configuration.
  ///
  /// This used to build a bare `Dio()` for the retry, which quietly defeated
  /// the whole mechanism on native: the DNS-over-HTTPS `connectionFactory`
  /// that DioClient installs lives on the original client, so a retry through
  /// a fresh instance went back through the same hijacked OS resolver that had
  /// just failed — in exactly the scenario (a sinkholed TMDb domain) this
  /// interceptor exists for. It also bypassed the response cache.
  final Dio _dio;

  /// Marks a request that is already a failover attempt, so a second failure
  /// can't send it round again.
  static const String _retriedFlag = 'cinefile.failover.retried';

  // Official TMDb domains only. We deliberately do not fall back to
  // third-party CORS proxies (e.g. corsproxy.io): doing so would send the
  // user's TMDb API key, in the request URL, to an untrusted service.
  static const List<String> baseUrls = [
    'https://api.themoviedb.org/3',
    'https://api.tmdb.org/3',
  ];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Catch all connection errors, timeouts, and unknown browser errors (CORS/ISP blocks on Web)
    if (err.type == DioExceptionType.badResponse ||
        err.type == DioExceptionType.cancel ||
        err.requestOptions.extra[_retriedFlag] == true) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final currentIndex = baseUrls.indexOf(options.baseUrl);
    if (currentIndex == -1 || currentIndex >= baseUrls.length - 1) {
      return handler.next(err);
    }

    final nextBaseUrl = baseUrls[currentIndex + 1];
    // A copy rather than a mutation of `err.requestOptions`: that object is
    // the caller's, is what the cache interceptor derives its key from, and is
    // still referenced by the DioException being propagated if the retry also
    // fails.
    final retryOptions = options.copyWith(
      baseUrl: nextBaseUrl,
      path: options.path.startsWith('http')
          ? options.path.replaceFirst(baseUrls[currentIndex], nextBaseUrl)
          : options.path,
      extra: {...options.extra, _retriedFlag: true},
    );

    try {
      return handler.resolve(await _dio.fetch(retryOptions));
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }
}
