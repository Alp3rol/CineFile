import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/tmdb_service.dart';
import '../domain/graph_models.dart';

/// Safety cap on the number of "bridge" people rendered. The bridge rule
/// (a person must connect ≥2 titles) already keeps this low for realistic
/// libraries; for a pathological library we keep the most-connected people
/// (highest degree) and drop the long tail so the canvas stays responsive.
const int kMaxPersonNodes = 400;


/// Max titles fetched concurrently, so a large library doesn't open hundreds of
/// simultaneous TMDb connections. Repeat runs are cheap (Dio memory cache).
const int _kFetchConcurrency = 6;

/// One person in a title's credits. [id] is the TMDb person id when known
/// (full-credits path); null only on the offline/stored-names fallback, where
/// people are matched by normalized name instead.
class CreditPerson {
  final int? id;
  final String name;
  final String? profilePath;
  final bool isDirector;
  const CreditPerson({
    this.id,
    required this.name,
    this.profilePath,
    required this.isDirector,
  });
}

/// Indirection point for fetching a title's credits, so widget tests can
/// override it with a network-free stub (returning [] → the builder falls back
/// to the movie's stored names, which are set in test fixtures).
final titleCreditsFetcherProvider =
    Provider<Future<List<CreditPerson>> Function(Movie)>((ref) {
  final service = ref.read(tmdbServiceProvider);
  return (movie) => _fetchCredits(service, movie);
});

/// The graph, enriched with each title's FULL cast (by person id) from TMDb.
/// Async because it fetches credits; falls back to the stored top-5 names per
/// title when a fetch fails (offline), so it always produces something.
final relationshipGraphProvider = FutureProvider<RelationshipGraph>((ref) async {
  final records = await ref.watch(allWatchRecordsProvider.future);

  // Unique titles keyed by (tmdbId, isTv).
  final titles = <String, Movie>{};
  for (final r in records) {
    titles.putIfAbsent(_titleId(r.movie.tmdbId, r.movie.isTv), () => r.movie);
  }
  if (titles.isEmpty) return const RelationshipGraph(nodes: [], edges: []);

  final fetch = ref.read(titleCreditsFetcherProvider);
  final creditsByTitle = <String, List<CreditPerson>>{};
  final entries = titles.entries.toList();
  for (var i = 0; i < entries.length; i += _kFetchConcurrency) {
    final chunk = entries.skip(i).take(_kFetchConcurrency);
    await Future.wait(chunk.map((e) async {
      creditsByTitle[e.key] = await fetch(e.value);
    }));
  }

  return buildGraphFromCredits(titles, creditsByTitle);
});

/// Fetches a title's full credits from TMDb and maps them to [CreditPerson]s.
/// Prefers TV `aggregate_credits` (the whole recurring cast) over the flat
/// `credits.cast`. Returns [] on any failure so the caller can fall back.
Future<List<CreditPerson>> _fetchCredits(
    TmdbService service, Movie movie) async {
  try {
    final data = await service.getMovieDetails(movie.tmdbId, isTv: movie.isTv);
    if (data == null) return const [];
    final credits = data['credits'] as Map<String, dynamic>?;
    final aggregate = data['aggregate_credits'] as Map<String, dynamic>?;
    final castRaw = (aggregate?['cast'] as List<dynamic>?) ??
        (credits?['cast'] as List<dynamic>?) ??
        const [];
    final crewRaw = (credits?['crew'] as List<dynamic>?) ?? const [];

    // The FULL cast is kept intentionally: a real case had a bridge actor
    // billed ~500th in a big Turkish show's aggregate credits, so any per-title
    // cap dropped him. The bridge rule (≥2 shared titles) plus the highest-
    // degree [kMaxPersonNodes] cap bound the final node count instead.
    final people = <CreditPerson>[];
    for (final c in castRaw) {
      final name = (c['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      people.add(CreditPerson(
        id: c['id'] as int?,
        name: name,
        profilePath: c['profile_path'] as String?,
        isDirector: false,
      ));
    }
    for (final c in crewRaw) {
      if (c['job'] != 'Director') continue;
      final name = (c['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      people.add(CreditPerson(
        id: c['id'] as int?,
        name: name,
        profilePath: c['profile_path'] as String?,
        isDirector: true,
      ));
    }
    if (people.isNotEmpty) return people;
  } catch (_) {
    // fall through to the stored-names fallback
  }
  return _fallbackFromStoredNames(movie);
}

/// Offline fallback: the lossy top-5 `actors` / single `director` strings the
/// DB already persists. Name-keyed (no ids), so it degrades to v1 behavior.
List<CreditPerson> _fallbackFromStoredNames(Movie movie) {
  final people = <CreditPerson>[];
  final dir = movie.director;
  if (dir != null) {
    for (final d in dir.split(',')) {
      final name = d.trim();
      if (name.isNotEmpty) {
        people.add(CreditPerson(name: name, isDirector: true));
      }
    }
  }
  final actors = movie.actors;
  if (actors != null) {
    for (final a in actors.split(',')) {
      final name = a.trim();
      if (name.isNotEmpty) {
        people.add(CreditPerson(name: name, isDirector: false));
      }
    }
  }
  return people;
}

/// Pure builder over already-fetched credits — testable without Riverpod.
/// A person bridges titles when they appear in ≥2 of them; person identity is
/// the TMDb id when available, else the normalized name.
RelationshipGraph buildGraphFromCredits(
  Map<String, Movie> titles,
  Map<String, List<CreditPerson>> creditsByTitle,
) {
  final titleNodes = <String, GraphNode>{};
  titles.forEach((id, m) {
    titleNodes[id] = GraphNode(
      id: id,
      type: m.isTv ? GraphNodeType.tv : GraphNodeType.movie,
      label: m.title,
      imageUrl: _imageUrl(m.posterPath),
      tmdbId: m.tmdbId,
      isTv: m.isTv,
    );
  });

  final people = <String, _PersonAgg>{};
  creditsByTitle.forEach((titleId, credits) {
    if (!titleNodes.containsKey(titleId)) return;
    for (final p in credits) {
      final key = p.id != null ? 'id:${p.id}' : 'nm:${_normalize(p.name)}';
      if (key == 'nm:') continue;
      final agg = people.putIfAbsent(
        key,
        () => _PersonAgg(key, p.name, p.id, p.profilePath),
      );
      agg.profilePath ??= p.profilePath;
      final role = p.isDirector ? GraphEdgeType.directed : GraphEdgeType.actedIn;
      final existing = agg.titleRoles[titleId];
      if (existing == null || role == GraphEdgeType.directed) {
        agg.titleRoles[titleId] = role;
      }
      if (p.isDirector) agg.directedAny = true;
      if (!p.isDirector) agg.actedAny = true;
    }
  });

  final bridges = people.values.where((p) => p.titleRoles.length >= 2).toList()
    ..sort((a, b) => b.titleRoles.length.compareTo(a.titleRoles.length));

  final personNodes = <GraphNode>[];
  final edges = <GraphEdge>[];
  for (final p in bridges.take(kMaxPersonNodes)) {
    final pid = 'person:${p.key}';
    personNodes.add(GraphNode(
      id: pid,
      type: p.directedAny ? GraphNodeType.director : GraphNodeType.actor,
      label: p.displayName,
      imageUrl: _imageUrl(p.profilePath),
      tmdbId: p.id,
      degree: p.titleRoles.length,
    ));
    p.titleRoles.forEach((titleId, role) {
      edges.add(GraphEdge(sourceId: titleId, targetId: pid, type: role));
      titleNodes[titleId]!.degree += 1;
    });
  }

  final connectedTitleIds = <String>{for (final e in edges) e.sourceId};
  final keptTitles =
      titleNodes.values.where((n) => connectedTitleIds.contains(n.id)).toList();

  return RelationshipGraph(
    nodes: [...keptTitles, ...personNodes],
    edges: edges,
  );
}

/// Name-only graph builder (no ids). Retained as the pure reference logic used
/// by unit tests and mirrored by [_fallbackFromStoredNames] at runtime.
RelationshipGraph buildRelationshipGraph(List<WatchRecordWithMovie> records) {
  final titles = <String, Movie>{};
  final credits = <String, List<CreditPerson>>{};
  for (final r in records) {
    final id = _titleId(r.movie.tmdbId, r.movie.isTv);
    titles.putIfAbsent(id, () => r.movie);
    credits[id] = _fallbackFromStoredNames(r.movie);
  }
  return buildGraphFromCredits(titles, credits);
}

String _titleId(int tmdbId, bool isTv) => 'title:$tmdbId:$isTv';

String _normalize(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String? _imageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  return '${ApiConstants.imagePathW185}$path';
}

class _PersonAgg {
  final String key;
  final String displayName;
  final int? id;
  String? profilePath;
  final Map<String, GraphEdgeType> titleRoles = {}; // titleId -> role
  bool directedAny = false;
  bool actedAny = false;
  _PersonAgg(this.key, this.displayName, this.id, this.profilePath);
}
