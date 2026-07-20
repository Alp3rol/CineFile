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
            connectTimeout: const Duration(milliseconds: 1500), // Fast timeout for quick fallback to the alternate TMDb domain
            receiveTimeout: const Duration(seconds: 3),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(FailoverInterceptor());
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
    ));

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
            throw SocketException('DNS engellendi ve DoH çözümlemesi başarısız: ${uri.host}');
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
  // Official TMDb domains only. We deliberately do not fall back to
  // third-party CORS proxies (e.g. corsproxy.io): doing so would send the
  // user's TMDb API key, in the request URL, to an untrusted service.
  final List<String> baseUrls = [
    'https://api.themoviedb.org/3',
    'https://api.tmdb.org/3',
  ];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Catch all connection errors, timeouts, and unknown browser errors (CORS/ISP blocks on Web)
    if (err.type != DioExceptionType.badResponse &&
        err.type != DioExceptionType.cancel) {
      final options = err.requestOptions;
      final currentBaseUrl = options.baseUrl;

      // Try the next official base URL, if there is one left to try.
      final currentIndex = baseUrls.indexOf(currentBaseUrl);
      if (currentIndex != -1 && currentIndex < baseUrls.length - 1) {
        final nextBaseUrl = baseUrls[currentIndex + 1];
        if (options.path.startsWith('http')) {
          options.path = options.path.replaceFirst(currentBaseUrl, nextBaseUrl);
        }
        options.baseUrl = nextBaseUrl;

        try {
          final retryDio = Dio();
          final response = await retryDio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }
    }
    return handler.next(err);
  }
}
