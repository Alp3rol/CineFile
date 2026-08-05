import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/observability/error_reporting.dart';
import '../domain/graph_models.dart';

/// How long a cached credits entry is trusted.
///
/// Credits do change — a cast list gets corrected, a running show's episode
/// counts grow — but not on the timescale of a session. A month keeps the graph
/// accurate while making the common case (opening the tab again tomorrow) cost
/// nothing.
const Duration kTitleCreditsTtl = Duration(days: 30);

/// Persistent store for the İlişki Ağı's per-title TMDb credits.
///
/// Without this, [rawTitleCreditsProvider] issued one TMDb request per unique
/// watched title on the first open of the graph tab in *every* session: a
/// 300-title library meant 300 requests, repeated on every app start, because
/// the only cache in the path was Dio's in-memory store.
abstract class TitleCreditsCache {
  Future<Map<MovieKey, List<CreditPerson>>> read(Iterable<MovieKey> keys);
  Future<void> write(MovieKey key, List<CreditPerson> people);
}

final titleCreditsCacheProvider = Provider<TitleCreditsCache>((ref) {
  // Web has no Drift database (see database_provider.dart), so it keeps the
  // previous behaviour: a per-session in-memory cache.
  return kIsWeb ? MemoryTitleCreditsCache() : _DriftTitleCreditsCache(ref);
});

List<CreditPerson> _decode(String json) => (jsonDecode(json) as List<dynamic>)
    .whereType<Map<String, dynamic>>()
    .map(CreditPerson.fromCacheMap)
    .toList();

String _encode(List<CreditPerson> people) =>
    jsonEncode(people.map((p) => p.toCacheMap()).toList());

class _DriftTitleCreditsCache implements TitleCreditsCache {
  _DriftTitleCreditsCache(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);

  @override
  Future<Map<MovieKey, List<CreditPerson>>> read(
    Iterable<MovieKey> keys,
  ) async {
    final ids = keys.map((k) => k.tmdbId).toSet();
    if (ids.isEmpty) return const {};

    // One query for the whole batch. tmdbId.isIn alone can match both a movie
    // and a show sharing the same numeric id, so the (tmdbId, isTv) pair is
    // matched in Dart — same reasoning as _mirrorSharedCollection.
    final rows = await (_db.select(
      _db.titleCredits,
    )..where((t) => t.tmdbId.isIn(ids))).get();

    final wanted = keys.toSet();
    final cutoff = DateTime.now().subtract(kTitleCreditsTtl);
    final result = <MovieKey, List<CreditPerson>>{};
    for (final row in rows) {
      final key = (tmdbId: row.tmdbId, isTv: row.isTv);
      if (!wanted.contains(key)) continue;
      if (row.fetchedAt.isBefore(cutoff)) continue;
      try {
        result[key] = _decode(row.people);
      } catch (error, stackTrace) {
        // A corrupt entry must not take the whole graph down with it; leaving
        // it out simply makes this title a cache miss.
        reportError(
          error,
          stackTrace,
          where: 'titleCreditsCache.decode.${key.tmdbId}_${key.isTv}',
        );
      }
    }
    return result;
  }

  @override
  Future<void> write(MovieKey key, List<CreditPerson> people) async {
    // An empty result is not cached: it usually means the request failed and
    // _fetchCredits fell through to its stored-names fallback, and persisting
    // that would keep the title out of the graph for a month.
    if (people.isEmpty) return;
    await _db
        .into(_db.titleCredits)
        .insertOnConflictUpdate(
          TitleCredit(
            tmdbId: key.tmdbId,
            isTv: key.isTv,
            people: _encode(people),
            fetchedAt: DateTime.now(),
          ),
        );
  }
}

/// In-memory implementation. Used on web, where there is no Drift database, and
/// by tests that exercise the graph without wanting a real one — override
/// [titleCreditsCacheProvider] with an instance of this alongside
/// [titleCreditsFetcherProvider].
class MemoryTitleCreditsCache implements TitleCreditsCache {
  final Map<MovieKey, List<CreditPerson>> _entries = {};

  @override
  Future<Map<MovieKey, List<CreditPerson>>> read(
    Iterable<MovieKey> keys,
  ) async {
    return {
      for (final key in keys)
        if (_entries.containsKey(key)) key: _entries[key]!,
    };
  }

  @override
  Future<void> write(MovieKey key, List<CreditPerson> people) async {
    if (people.isEmpty) return;
    _entries[key] = people;
  }
}
