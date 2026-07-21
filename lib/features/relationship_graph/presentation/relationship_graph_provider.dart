import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/database/database_provider.dart';
import '../domain/graph_models.dart';

/// Safety cap on the number of "bridge" people rendered. The bridge rule
/// (a person must connect ≥2 titles) already keeps this low for realistic
/// libraries; for a pathological library we keep the most-connected people
/// (highest degree) and drop the long tail so the canvas stays responsive.
const int kMaxPersonNodes = 400;

/// Builds the İlişki Ağı from the current user's watch history. Mirrors
/// [insightsProvider]: derives a value object from [allWatchRecordsProvider]
/// so it recomputes automatically whenever logs change, and works for web
/// guests too (name-based, so no network needed). Returns null while records
/// are still loading; the screen distinguishes loading vs. empty separately.
final relationshipGraphProvider = Provider<RelationshipGraph?>((ref) {
  final list = ref.watch(allWatchRecordsProvider).value;
  if (list == null) return null;
  return buildRelationshipGraph(list);
});

/// Pure builder (no Riverpod) so it can be unit-tested directly with a hand-
/// built record list. v1 links titles by the lossy comma-separated
/// `movie.director` / `movie.actors` name strings — the only person data the
/// DB currently persists. v2 will swap the person key from normalized-name to
/// TMDb personId without changing this function's shape.
RelationshipGraph buildRelationshipGraph(List<WatchRecordWithMovie> records) {
  // 1. One node per unique watched title, keyed by (tmdbId, isTv) since a
  //    movie and a show can share a numeric id.
  final titleNodes = <String, GraphNode>{};
  for (final r in records) {
    final m = r.movie;
    final id = _titleId(m.tmdbId, m.isTv);
    titleNodes.putIfAbsent(
      id,
      () => GraphNode(
        id: id,
        type: m.isTv ? GraphNodeType.tv : GraphNodeType.movie,
        label: m.title,
        imageUrl: _posterUrl(m.posterPath),
        tmdbId: m.tmdbId,
        isTv: m.isTv,
      ),
    );
  }

  // 2. Aggregate people across titles. Person identity is the normalized name.
  final people = <String, _PersonAgg>{};
  void addPerson(String rawName, String titleId, GraphEdgeType role) {
    final name = rawName.trim();
    if (name.isEmpty) return;
    final key = _normalize(name);
    if (key.isEmpty) return;
    final agg = people.putIfAbsent(key, () => _PersonAgg(name));
    // A director credit outranks an acting credit for the same title (so the
    // edge reads as "directed" rather than a coincidental cast listing).
    final existing = agg.titleRoles[titleId];
    if (existing == null || role == GraphEdgeType.directed) {
      agg.titleRoles[titleId] = role;
    }
    if (role == GraphEdgeType.directed) agg.directedAny = true;
    if (role == GraphEdgeType.actedIn) agg.actedAny = true;
  }

  for (final r in records) {
    final m = r.movie;
    final id = _titleId(m.tmdbId, m.isTv);
    final dir = m.director;
    if (dir != null) {
      for (final d in dir.split(',')) {
        addPerson(d, id, GraphEdgeType.directed);
      }
    }
    final actors = m.actors;
    if (actors != null) {
      for (final a in actors.split(',')) {
        addPerson(a, id, GraphEdgeType.actedIn);
      }
    }
  }

  // 3. Bridge rule: keep only people connecting ≥2 distinct titles, capped to
  //    the highest-degree kMaxPersonNodes.
  final bridges = people.values.where((p) => p.titleRoles.length >= 2).toList()
    ..sort((a, b) => b.titleRoles.length.compareTo(a.titleRoles.length));

  final personNodes = <GraphNode>[];
  final edges = <GraphEdge>[];
  for (final p in bridges.take(kMaxPersonNodes)) {
    final pid = 'person:${_normalize(p.displayName)}';
    personNodes.add(GraphNode(
      id: pid,
      // Icon/color hint only; each edge still carries its own precise role.
      type: p.directedAny ? GraphNodeType.director : GraphNodeType.actor,
      label: p.displayName,
      degree: p.titleRoles.length,
    ));
    p.titleRoles.forEach((titleId, role) {
      edges.add(GraphEdge(sourceId: titleId, targetId: pid, type: role));
      titleNodes[titleId]!.degree += 1;
    });
  }

  // 4. Drop isolated titles (no bridge touches them) — they'd be lone islands.
  final connectedTitleIds = <String>{for (final e in edges) e.sourceId};
  final keptTitles =
      titleNodes.values.where((n) => connectedTitleIds.contains(n.id)).toList();

  return RelationshipGraph(
    nodes: [...keptTitles, ...personNodes],
    edges: edges,
  );
}

String _titleId(int tmdbId, bool isTv) => 'title:$tmdbId:$isTv';

/// Turkish names vary in casing/spacing across TMDb payloads; normalize to a
/// stable dedup key. Not locale-aware (Dart's toLowerCase isn't), but
/// consistent, which is all dedup needs.
String _normalize(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String? _posterUrl(String? posterPath) {
  if (posterPath == null || posterPath.isEmpty) return null;
  return '${ApiConstants.imagePathW185}$posterPath';
}

class _PersonAgg {
  final String displayName;
  final Map<String, GraphEdgeType> titleRoles = {}; // titleId -> role
  bool directedAny = false;
  bool actedAny = false;
  _PersonAgg(this.displayName);
}
