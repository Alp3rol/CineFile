import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Resolves hostnames via DNS-over-HTTPS instead of the OS/router resolver.
///
/// Some routers/ISPs hijack plain UDP DNS lookups for specific domains
/// (observed in the wild: api.themoviedb.org / api.tmdb.org silently
/// resolving to 127.0.0.1, even when a different DNS server is explicitly
/// requested). DoH runs the lookup over HTTPS to a well-known resolver IP,
/// which such interception generally does not touch, so it lets the app
/// recover automatically without the user having to change any network
/// settings.
class DohResolver {
  DohResolver._();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static const List<String> _providers = [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/resolve',
  ];

  static final Map<String, _CachedIp> _cache = {};

  /// Returns a resolved [InternetAddress] for [hostname], or null if every
  /// DoH provider failed (caller should fall back to normal DNS in that case).
  static Future<InternetAddress?> resolve(String hostname) async {
    final cached = _cache[hostname];
    if (cached != null && !cached.isExpired) return cached.address;

    for (final provider in _providers) {
      try {
        final response = await _dio.get(
          provider,
          queryParameters: {'name': hostname, 'type': 'A'},
          options: Options(headers: {'Accept': 'application/dns-json'}),
        );
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        final answers = data['Answer'] as List<dynamic>?;
        if (answers == null) continue;

        final aRecord = answers.cast<Map<String, dynamic>?>().firstWhere(
              (a) => a?['type'] == 1,
              orElse: () => null,
            );
        final ip = aRecord?['data'] as String?;
        if (ip == null) continue;

        final address = InternetAddress(ip);
        _cache[hostname] = _CachedIp(address, DateTime.now().add(const Duration(minutes: 10)));
        return address;
      } catch (e) {
        debugPrint('DohResolver: $provider failed for $hostname: $e');
      }
    }
    return null;
  }
}

class _CachedIp {
  final InternetAddress address;
  final DateTime expiresAt;
  _CachedIp(this.address, this.expiresAt);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
