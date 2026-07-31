// Every TMDb request goes through the Cloudflare Worker in tools/tmdb-proxy,
// whose ALLOWED_PATHS is an allowlist: an unlisted path returns 404.
//
// That mismatch is invisible in normal development. A build without
// TMDB_PROXY_URL talks to TMDb directly and never touches the worker, so the
// feature works on the dev machine and in the default CI run and fails only in
// the web/proxy build — where the 404 surfaces as an empty result, which looks
// exactly like "TMDb has no data for this title". It has already caused one
// outage.
//
// This test closes that gap at PR time by reading both files as text and
// checking that every path the service requests is one the worker will accept.
// String scraping is admittedly brittle; the alternative is finding out in
// production.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every request-path literal in TmdbService, with `$interp` segments replaced
/// by a concrete id so they can be matched against the worker's regexes.
///
/// Deliberately matches ALL `'/...'` literals rather than only those sitting
/// directly inside `_dio.get('...')`. An earlier version anchored on the call
/// and silently scraped nothing from
/// `_dio.get(isTv ? '/tv/...' : '/movie/...')` — so the check passed while
/// covering neither path. Scraping every path-shaped literal errs toward false
/// positives, and a false positive here costs one allowlist entry, whereas a
/// false negative costs an outage.
List<String> _servicePaths(String source) {
  // The offline demo payload carries TMDb poster paths, which are data rather
  // than endpoints.
  final imagePath = RegExp(r'\.(jpg|jpeg|png|webp|svg)$', caseSensitive: false);

  return RegExp(r"'(/[^']*)'")
      .allMatches(source)
      .map((m) => m.group(1)!)
      .where((path) => !imagePath.hasMatch(path))
      .map((path) => path.replaceAll(RegExp(r'\$\{[^}]*\}|\$\w+'), '1'))
      .toSet()
      .toList();
}

/// Regex sources from the worker's ALLOWED_PATHS array literal.
List<RegExp> _allowlist(String source) {
  final block = RegExp(r'const ALLOWED_PATHS = \[(.*?)\];', dotAll: true).firstMatch(source);
  expect(block, isNotNull, reason: 'ALLOWED_PATHS array not found in the worker source');
  return RegExp(r'/\^(.*?)\$/')
      .allMatches(block!.group(1)!)
      .map((m) => RegExp('^${m.group(1)!}\$'))
      .toList();
}

void main() {
  late List<String> servicePaths;
  late List<RegExp> allowlist;

  setUpAll(() {
    // cwd is the package root under `flutter test`.
    servicePaths = _servicePaths(File('lib/core/network/tmdb_service.dart').readAsStringSync());
    allowlist = _allowlist(File('tools/tmdb-proxy/src/index.js').readAsStringSync());
  });

  test('the scrapers actually found something', () {
    // Without this, a refactor that changes either file's shape would turn the
    // real assertion below into a vacuous pass.
    expect(servicePaths, isNotEmpty, reason: 'no _dio.get paths scraped from TmdbService');
    expect(allowlist, hasLength(greaterThan(5)), reason: 'no regexes scraped from ALLOWED_PATHS');
  });

  test('every endpoint TmdbService calls is allowed by the proxy', () {
    final unmatched = servicePaths
        .where((path) => !allowlist.any((re) => re.hasMatch(path)))
        .toSet();

    expect(
      unmatched,
      isEmpty,
      reason: 'These paths would 404 through the proxy. Add a regex to ALLOWED_PATHS in '
          'tools/tmdb-proxy/src/index.js and redeploy the worker '
          '(see tools/tmdb-proxy/README.md).',
    );
  });

  test('the allowlist stays a genuine allowlist', () {
    // A catch-all entry would make the test above pass forever while removing
    // the protection the worker exists to provide.
    for (final path in ['/account/123', '/movie/1/reviews', '/anything']) {
      expect(
        allowlist.any((re) => re.hasMatch(path)),
        isFalse,
        reason: '$path should not be proxied',
      );
    }
  });
}
