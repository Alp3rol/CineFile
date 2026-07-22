import 'map_graph.dart';

/// Deterministic weighted label-propagation community detection over the
/// title↔title graph. Returns titleId → clusterId, with clusters renumbered to
/// a stable 0..k-1 (by first appearance in sorted title order). Isolated titles
/// (no links) keep their own singleton cluster.
///
/// In-place async updates in a fixed (sorted) node order + smallest-label
/// tie-breaking make the result reproducible for the same input.
Map<String, int> labelPropagationClusters(
  List<String> titleIds,
  List<TitleLink> links, {
  int iterations = 20,
}) {
  final nodes = [...titleIds]..sort();
  if (nodes.isEmpty) return const {};

  // Weighted adjacency.
  final adj = <String, List<MapEntry<String, int>>>{
    for (final id in nodes) id: <MapEntry<String, int>>[],
  };
  for (final l in links) {
    if (!adj.containsKey(l.aId) || !adj.containsKey(l.bId)) continue;
    adj[l.aId]!.add(MapEntry(l.bId, l.weight));
    adj[l.bId]!.add(MapEntry(l.aId, l.weight));
  }

  // Seed each node with a unique label.
  final label = <String, int>{for (var i = 0; i < nodes.length; i++) nodes[i]: i};

  for (var it = 0; it < iterations; it++) {
    var changed = false;
    for (final node in nodes) {
      final neighbors = adj[node]!;
      if (neighbors.isEmpty) continue; // isolated → keep singleton label

      // Weighted vote over neighbor labels.
      final votes = <int, int>{};
      for (final n in neighbors) {
        final l = label[n.key]!;
        votes[l] = (votes[l] ?? 0) + n.value;
      }
      var bestLabel = label[node]!;
      var bestScore = -1;
      votes.forEach((l, score) {
        if (score > bestScore || (score == bestScore && l < bestLabel)) {
          bestScore = score;
          bestLabel = l;
        }
      });
      if (bestLabel != label[node]) {
        label[node] = bestLabel;
        changed = true;
      }
    }
    if (!changed) break;
  }

  // Renumber to stable 0..k-1 by first appearance in sorted order.
  final remap = <int, int>{};
  var next = 0;
  final result = <String, int>{};
  for (final node in nodes) {
    final raw = label[node]!;
    final id = remap.putIfAbsent(raw, () => next++);
    result[node] = id;
  }
  return result;
}
