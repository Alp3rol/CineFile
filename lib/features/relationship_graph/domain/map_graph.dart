import 'graph_models.dart';

/// A person on a title↔title link (who connects the two titles).
class PersonRef {
  final int? id;
  final String key;
  final String name;
  final String? profilePath;
  final bool isDirector;

  const PersonRef({
    this.id,
    required this.key,
    required this.name,
    this.profilePath,
    required this.isDirector,
  });
}

/// A direct connection between two watched titles. [weight] is how many people
/// they share; [people] is that shared cast/crew (for the edge-tap sheet).
class TitleLink {
  final String aId;
  final String bId;
  final int weight;
  final List<PersonRef> people;

  const TitleLink({
    required this.aId,
    required this.bId,
    required this.weight,
    required this.people,
  });

  /// Canonical, order-independent id for a title pair.
  static String idFor(String x, String y) =>
      (x.compareTo(y) <= 0) ? '$x|$y' : '$y|$x';

  String get id => idFor(aId, bId);
}

/// A detected community of titles ("galaxy") with an auto-generated label.
class GraphCluster {
  final int id;
  final String label;
  final List<String> titleIds;

  const GraphCluster({
    required this.id,
    required this.label,
    required this.titleIds,
  });

  int get size => titleIds.length;
}

/// Headline numbers shown in the insight card.
class MapInsights {
  final int clusterCount; // clusters with ≥2 members
  final int titleCount;
  final int linkCount;
  final PersonRef? mostCentralPerson;
  final int centralPersonTitleCount;
  final TitleLink? strongestPair;
  final GraphCluster? biggestCluster;

  const MapInsights({
    required this.clusterCount,
    required this.titleCount,
    required this.linkCount,
    required this.mostCentralPerson,
    required this.centralPersonTitleCount,
    required this.strongestPair,
    required this.biggestCluster,
  });

  static const MapInsights empty = MapInsights(
    clusterCount: 0,
    titleCount: 0,
    linkCount: 0,
    mostCentralPerson: null,
    centralPersonTitleCount: 0,
    strongestPair: null,
    biggestCluster: null,
  );
}

/// The clustered map of the user's watched titles. [titles] holds ALL watched
/// titles (isolated ones included), each tagged with a [GraphNode.clusterId].
class MapGraph {
  final List<GraphNode> titles;
  final List<TitleLink> links;
  final List<GraphCluster> clusters;
  final MapInsights insights;

  const MapGraph({
    required this.titles,
    required this.links,
    required this.clusters,
    required this.insights,
  });

  static const MapGraph empty = MapGraph(
    titles: [],
    links: [],
    clusters: [],
    insights: MapInsights.empty,
  );

  bool get hasTitles => titles.isNotEmpty;
  bool get hasLinks => links.isNotEmpty;

  Map<String, TitleLink> get linkById => {for (final l in links) l.id: l};
  Map<String, GraphNode> get titleById => {for (final t in titles) t.id: t};
}
