import 'package:flutter/painting.dart' show Offset;

/// The kinds of nodes the İlişki Ağı (relationship graph) can contain.
///
/// v1 (name-based) only ever produces [movie], [tv], [actor] and [director].
/// The remaining values are reserved for the person-ID (v2) upgrade so the
/// enum — and every color/icon/filter map keyed off it — keeps the same shape
/// when writers / production companies / genres are added later.
enum GraphNodeType { movie, tv, actor, director, writer, producer, company, genre }

extension GraphNodeTypeX on GraphNodeType {
  bool get isTitle => this == GraphNodeType.movie || this == GraphNodeType.tv;
  bool get isPerson =>
      this == GraphNodeType.actor ||
      this == GraphNodeType.director ||
      this == GraphNodeType.writer ||
      this == GraphNodeType.producer;
}

/// A single node in the graph — either a watched title or a "bridge" person
/// that connects two or more watched titles.
///
/// [position] and [pinned] are deliberately mutable: the force-directed layout
/// engine writes positions in place, and dragging a node pins it there.
class GraphNode {
  final String id;
  final GraphNodeType type;
  final String label;

  /// Full poster/profile image URL, or null when none is available (the node
  /// falls back to a colored disc + icon).
  final String? imageUrl;

  /// For title nodes: the TMDb id and media type, so a node can deep-link to
  /// MovieDetailScreen. Null tmdbId for person nodes — name-based v1 has no
  /// person id (resolved on demand via TmdbService.searchPersonId instead).
  final int? tmdbId;
  final bool isTv;

  /// Number of edges touching this node — drives its rendered size/importance.
  int degree;

  /// Written by the layout engine and by drag interactions.
  Offset position;

  /// True once the user has dragged this node; the layout engine then leaves
  /// it fixed where the user placed it.
  bool pinned;

  GraphNode({
    required this.id,
    required this.type,
    required this.label,
    this.imageUrl,
    this.tmdbId,
    this.isTv = false,
    this.degree = 0,
    this.position = Offset.zero,
    this.pinned = false,
  });
}

/// The relationship an edge represents. In v1 only [actedIn] and [directed]
/// are produced; the rest mirror the reserved [GraphNodeType] values.
enum GraphEdgeType { actedIn, directed, wrote, produced, inCompany, inGenre }

extension GraphEdgeTypeX on GraphEdgeType {
  /// The person-node type that sits on the target end of this edge.
  GraphNodeType get personType {
    switch (this) {
      case GraphEdgeType.directed:
        return GraphNodeType.director;
      case GraphEdgeType.wrote:
        return GraphNodeType.writer;
      case GraphEdgeType.produced:
        return GraphNodeType.producer;
      case GraphEdgeType.inCompany:
        return GraphNodeType.company;
      case GraphEdgeType.inGenre:
        return GraphNodeType.genre;
      case GraphEdgeType.actedIn:
        return GraphNodeType.actor;
    }
  }
}

/// An undirected connection drawn as `title → person`. [weight] is 1 for a
/// single person↔title link; the collapsed title↔title view sums shared people
/// into a thicker line.
class GraphEdge {
  final String sourceId; // title node id
  final String targetId; // person node id
  final GraphEdgeType type;
  final int weight;

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.weight = 1,
  });
}

/// An immutable-topology graph value object. Node [position]s mutate during
/// layout, but the node/edge sets themselves are rebuilt whenever the
/// underlying watch records change.
class RelationshipGraph {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const RelationshipGraph({required this.nodes, required this.edges});

  /// A graph with no edges has nothing to visualize (every title would be an
  /// island) — the screen shows its empty state instead.
  bool get hasConnections => edges.isNotEmpty;

  Map<String, GraphNode> get nodesById => {for (final n in nodes) n.id: n};

  int get titleCount => nodes.where((n) => n.type.isTitle).length;
  int get personCount => nodes.where((n) => n.type.isPerson).length;
}

/// A person within a title's credits — either fetched from TMDb or supplied as
/// a manual override. [order] is billing order (movies & TV); [episodeCount] is
/// TV `aggregate_credits.total_episode_count`. Both drive the "prominence"
/// (öne çıkan kadro) default filter; they're null for manual adds and for the
/// offline stored-names fallback (which sets [order] by list position instead).
class CreditPerson {
  final int? id;
  final String name;
  final String? profilePath;
  final bool isDirector;
  final int? order;
  final int? episodeCount;

  const CreditPerson({
    this.id,
    required this.name,
    this.profilePath,
    required this.isDirector,
    this.order,
    this.episodeCount,
  });

  /// Persisted shape for a manual add (order/episodeCount are irrelevant there —
  /// manual adds always bypass the prominence filter).
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'profilePath': profilePath,
        'isDirector': isDirector,
      };

  factory CreditPerson.fromMap(Map<String, dynamic> m) => CreditPerson(
        id: m['id'] as int?,
        name: (m['name'] as String?) ?? '',
        profilePath: m['profilePath'] as String?,
        isDirector: (m['isDirector'] as bool?) ?? false,
      );
}

String normalizePersonName(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Stable person identity used everywhere (graph node ids, override keys):
/// the TMDb id when known, else the normalized name.
String personKeyFor({int? id, required String name}) =>
    id != null ? 'id:$id' : 'nm:${normalizePersonName(name)}';

String personKey(CreditPerson p) => personKeyFor(id: p.id, name: p.name);

/// How much of each title's cast the graph shows by default. [all] disables
/// the prominence filter entirely (v1 "full cast" behavior).
enum CastDepth { leads, featured, all }

/// Whether a person is "prominent" enough to appear by default at [depth].
/// Directors always are. Manual adds bypass this entirely (they're always
/// included by the builder), which is how a bridge TMDb billed 500th — or
/// doesn't credit at all — still shows once the user adds it.
bool isProminent(CreditPerson p, {required bool isTv, required CastDepth depth}) {
  if (p.isDirector) return true;
  if (depth == CastDepth.all) return true;
  final orderThreshold = depth == CastDepth.leads ? 8 : 12;
  final epThreshold = depth == CastDepth.leads ? 5 : 3;
  final order = p.order ?? 99999;
  if (isTv) {
    return (p.episodeCount ?? 0) >= epThreshold || order < orderThreshold;
  }
  return order < orderThreshold;
}
