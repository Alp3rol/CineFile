import '../../../core/constants/api_constants.dart';
import '../../../core/database/app_database.dart';
import 'graph_aggregation.dart';
import 'graph_clustering.dart';
import 'graph_models.dart';
import 'graph_overrides.dart';
import 'map_graph.dart';

/// Builds the clustered map: ALL watched titles as nodes, direct title↔title
/// links (weight = shared people), community clusters with auto labels, and
/// headline insights. Pure and testable; shares [aggregatePeople] with the
/// person-mediated builder so both views agree on connections.
MapGraph buildMapGraph(
  Map<String, Movie> titles,
  Map<String, List<CreditPerson>> creditsByTitle,
  GraphOverrides overrides,
  CastDepth depth,
) {
  if (titles.isEmpty) return MapGraph.empty;

  // Title nodes — every watched title, even ones that end up isolated.
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

  final agg = aggregatePeople(titles, creditsByTitle, overrides, depth);
  final personRefByKey = {
    for (final p in agg.values)
      p.key: PersonRef(
        id: p.id,
        key: p.key,
        name: p.displayName,
        profilePath: p.profilePath,
        isDirector: p.directedAny,
      ),
  };

  // Title↔title links from shared people.
  final linkAcc = <String, _LinkAcc>{};
  for (final p in agg.values) {
    final ids = p.titleRoles.keys.where(titleNodes.containsKey).toList()..sort();
    if (ids.length < 2) continue;
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final key = TitleLink.idFor(ids[i], ids[j]);
        final acc = linkAcc.putIfAbsent(key, () => _LinkAcc(ids[i], ids[j]));
        acc.people.add(personRefByKey[p.key]!);
      }
    }
  }
  final links = [
    for (final acc in linkAcc.values)
      TitleLink(
        aId: acc.aId,
        bId: acc.bId,
        weight: acc.people.length,
        people: acc.people,
      ),
  ]..sort((a, b) => b.weight.compareTo(a.weight));

  // Cluster the title↔title graph and tag nodes.
  final clusterOf = labelPropagationClusters(titleNodes.keys.toList(), links);
  clusterOf.forEach((titleId, cid) => titleNodes[titleId]!.clusterId = cid);

  // Group titles by cluster.
  final membersByCluster = <int, List<String>>{};
  clusterOf.forEach((titleId, cid) =>
      membersByCluster.putIfAbsent(cid, () => []).add(titleId));

  final clusters = <GraphCluster>[];
  membersByCluster.forEach((cid, members) {
    clusters.add(GraphCluster(
      id: cid,
      label: members.length >= 2
          ? _clusterLabel(members, titles, agg)
          : '',
      titleIds: members..sort(),
    ));
  });
  clusters.sort((a, b) => b.size.compareTo(a.size));

  // Insights.
  PersonAggregation? central;
  for (final p in agg.values) {
    if (central == null || p.degree > central.degree) central = p;
  }
  final bigClusters = clusters.where((c) => c.size >= 2).toList();

  final insights = MapInsights(
    clusterCount: bigClusters.length,
    titleCount: titleNodes.length,
    linkCount: links.length,
    mostCentralPerson:
        (central != null && central.degree >= 2) ? personRefByKey[central.key] : null,
    centralPersonTitleCount: central?.degree ?? 0,
    strongestPair: links.isEmpty ? null : links.first,
    biggestCluster: bigClusters.isEmpty ? null : bigClusters.first,
  );

  return MapGraph(
    titles: titleNodes.values.toList(),
    links: links,
    clusters: clusters,
    insights: insights,
  );
}

/// Cluster label: the person connecting the most member titles becomes their
/// "evreni" (e.g. "Zeki Demirkubuz evreni"); else the dominant genre becomes a
/// "kümesi" (e.g. "Polisiye kümesi"); else "Bağlantısız".
String _clusterLabel(
  List<String> memberIds,
  Map<String, Movie> titles,
  Map<String, PersonAggregation> agg,
) {
  final memberSet = memberIds.toSet();
  PersonAggregation? best;
  var bestCount = 0;
  for (final p in agg.values) {
    var count = 0;
    for (final t in p.titleRoles.keys) {
      if (memberSet.contains(t)) count++;
    }
    if (count > bestCount ||
        (count == bestCount && best != null && p.degree > best.degree)) {
      bestCount = count;
      best = p;
    }
  }
  if (best != null && bestCount >= 2) return '${best.displayName} evreni';

  final genreCounts = <String, int>{};
  for (final id in memberIds) {
    final g = titles[id]?.genres;
    if (g == null) continue;
    for (final part in g.split(',')) {
      final name = part.trim();
      if (name.isNotEmpty) genreCounts[name] = (genreCounts[name] ?? 0) + 1;
    }
  }
  if (genreCounts.isNotEmpty) {
    final top = genreCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${top.key} kümesi';
  }
  return 'Bağlantısız';
}

String? _imageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  return '${ApiConstants.imagePathW185}$path';
}

class _LinkAcc {
  final String aId;
  final String bId;
  final List<PersonRef> people = [];
  _LinkAcc(this.aId, this.bId);
}
