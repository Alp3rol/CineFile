import 'graph_models.dart';

/// The result of a shortest-path query between two graph nodes.
class GraphPathResult {
  final String startId;
  final String targetId;
  final List<String> nodeIds;
  final List<GraphEdge> edges;

  const GraphPathResult({
    required this.startId,
    required this.targetId,
    required this.nodeIds,
    required this.edges,
  });

  int get distance => edges.length;
  bool get isValid => nodeIds.isNotEmpty;
}

/// Finds the shortest connection path between two nodes in [graph] using
/// Breadth-First Search (BFS). Returns null if no connection exists.
GraphPathResult? findShortestPath(
  RelationshipGraph graph,
  String startId,
  String targetId,
) {
  if (startId == targetId) {
    return GraphPathResult(
      startId: startId,
      targetId: targetId,
      nodeIds: [startId],
      edges: const [],
    );
  }

  final byId = graph.nodesById;
  if (!byId.containsKey(startId) || !byId.containsKey(targetId)) {
    return null;
  }

  // Build adjacency list: nodeId -> Map<neighborId, GraphEdge>
  final adj = <String, Map<String, GraphEdge>>{};
  for (final edge in graph.edges) {
    adj.putIfAbsent(edge.sourceId, () => {})[edge.targetId] = edge;
    adj.putIfAbsent(edge.targetId, () => {})[edge.sourceId] = edge;
  }

  final queue = <String>[startId];
  final visited = <String>{startId};
  final parentNode = <String, String>{};
  final parentEdge = <String, GraphEdge>{};

  var found = false;
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (current == targetId) {
      found = true;
      break;
    }

    final neighbors = adj[current] ?? const {};
    for (final entry in neighbors.entries) {
      final neighborId = entry.key;
      final edge = entry.value;

      if (!visited.contains(neighborId)) {
        visited.add(neighborId);
        parentNode[neighborId] = current;
        parentEdge[neighborId] = edge;
        queue.add(neighborId);
      }
    }
  }

  if (!found) return null;

  // Reconstruct path from targetId back to startId
  final nodePath = <String>[];
  final edgePath = <GraphEdge>[];

  String? curr = targetId;
  while (curr != null) {
    nodePath.add(curr);
    final prevEdge = parentEdge[curr];
    if (prevEdge != null) edgePath.add(prevEdge);
    curr = parentNode[curr];
  }

  return GraphPathResult(
    startId: startId,
    targetId: targetId,
    nodeIds: nodePath.reversed.toList(),
    edges: edgePath.reversed.toList(),
  );
}
