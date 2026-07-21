import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/tmdb_service.dart';
import '../domain/graph_models.dart';
import '../domain/graph_overrides.dart';
import 'graph_overrides_provider.dart';

/// Safety cap on the number of "bridge" people rendered. The bridge rule
/// (a person must connect ≥2 titles) already keeps this low for realistic
/// libraries; for a pathological library we keep the most-connected people
/// (highest degree) and drop the long tail so the canvas stays responsive.
const int kMaxPersonNodes = 400;

/// Max titles fetched concurrently, so a large library doesn't open hundreds of
/// simultaneous TMDb connections. Repeat runs are cheap (Dio memory cache).
const int _kFetchConcurrency = 6;

/// The user-adjustable "kadro derinliği" (how much of each title's cast the
/// graph shows by default). Changing it re-curates instantly — no refetch,
/// since the raw credits are cached separately.
final graphCastDepthProvider =
    StateProvider<CastDepth>((_) => CastDepth.featured);

/// Test seam for fetching a title's credits (overridable to avoid network).
final titleCreditsFetcherProvider =
    Provider<Future<List<CreditPerson>> Function(Movie)>((ref) {
  final service = ref.read(tmdbServiceProvider);
  return (movie) => _fetchCredits(service, movie);
});

/// Raw, un-curated credits per watched title, fetched from TMDb. Heavy, but
/// only recomputed when the watch records change — depth/override tweaks reuse
/// this cache. Returns titles too so the builder needs no second source.
final rawTitleCreditsProvider = FutureProvider<
    ({Map<String, Movie> titles, Map<String, List<CreditPerson>> credits})>(
  (ref) async {
    final records = await ref.watch(allWatchRecordsProvider.future);

    final titles = <String, Movie>{};
    for (final r in records) {
      titles.putIfAbsent(_titleId(r.movie.tmdbId, r.movie.isTv), () => r.movie);
    }
    final credits = <String, List<CreditPerson>>{};
    if (titles.isEmpty) return (titles: titles, credits: credits);

    final fetch = ref.read(titleCreditsFetcherProvider);
    final entries = titles.entries.toList();
    for (var i = 0; i < entries.length; i += _kFetchConcurrency) {
      final chunk = entries.skip(i).take(_kFetchConcurrency);
      await Future.wait(chunk.map((e) async {
        credits[e.key] = await fetch(e.value);
      }));
    }
    return (titles: titles, credits: credits);
  },
);

/// The curated graph: raw credits filtered by the prominence default and the
/// user's manual add/remove/hide overrides. A plain [Provider] over cached
/// inputs, so depth and override changes rebuild only this cheap step.
final relationshipGraphProvider = Provider<AsyncValue<RelationshipGraph>>((ref) {
  final rawAsync = ref.watch(rawTitleCreditsProvider);
  final overrides = ref.watch(graphOverridesProvider).value ?? GraphOverrides.empty;
  final depth = ref.watch(graphCastDepthProvider);
  return rawAsync
      .whenData((raw) => buildCuratedGraph(raw.titles, raw.credits, overrides, depth));
});

/// Fetches a title's full credits from TMDb, capturing billing order and (for
/// TV) episode counts for the prominence filter. Prefers TV `aggregate_credits`
/// over the flat `credits.cast`. Returns the stored-names fallback on failure.
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

    final people = <CreditPerson>[];
    for (final c in castRaw) {
      final name = (c['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      people.add(CreditPerson(
        id: c['id'] as int?,
        name: name,
        profilePath: c['profile_path'] as String?,
        isDirector: false,
        order: c['order'] as int?,
        episodeCount: c['total_episode_count'] as int?,
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

/// Offline fallback: the DB's lossy top-5 `actors` / single `director` strings.
/// These ARE the leads, so [order] is set by list position → they pass the
/// prominence filter even though TMDb order is unavailable offline.
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
    var i = 0;
    for (final a in actors.split(',')) {
      final name = a.trim();
      if (name.isNotEmpty) {
        people.add(CreditPerson(name: name, isDirector: false, order: i++));
      }
    }
  }
  return people;
}

/// Pure, testable builder. Includes a person in a title when they're prominent
/// at [depth], OR promoted (manually added somewhere), OR a manual add for this
/// title — minus per-title removals and global hides. Then applies the bridge
/// rule (≥2 titles) and the [kMaxPersonNodes] cap.
RelationshipGraph buildCuratedGraph(
  Map<String, Movie> titles,
  Map<String, List<CreditPerson>> creditsByTitle,
  GraphOverrides overrides,
  CastDepth depth,
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

  final promoted = overrides.promotedKeys;
  final people = <String, _PersonAgg>{};

  void ingest(String titleId, CreditPerson p) {
    final key = personKey(p);
    if (key == 'nm:') return;
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

  titles.forEach((titleId, movie) {
    final tOv = overrides.forTitle(titleId);
    final removed = tOv.removedKeys;
    for (final p in creditsByTitle[titleId] ?? const []) {
      final key = personKey(p);
      if (removed.contains(key)) continue;
      if (!isProminent(p, isTv: movie.isTv, depth: depth) &&
          !promoted.contains(key)) {
        continue;
      }
      ingest(titleId, p);
    }
    for (final p in tOv.added) {
      if (removed.contains(personKey(p))) continue;
      ingest(titleId, p);
    }
  });

  for (final key in overrides.hiddenKeys) {
    people.remove(key);
  }

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

/// Uncurated build (full cast, no overrides) — used by unit tests and as the
/// [CastDepth.all] equivalent.
RelationshipGraph buildGraphFromCredits(
  Map<String, Movie> titles,
  Map<String, List<CreditPerson>> creditsByTitle,
) =>
    buildCuratedGraph(titles, creditsByTitle, GraphOverrides.empty, CastDepth.all);

/// Name-only build from the stored `actors`/`director` strings. Retained as the
/// pure reference used by unit tests and mirrored by [_fallbackFromStoredNames].
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
