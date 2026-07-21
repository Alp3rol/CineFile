import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/relationship_graph/domain/graph_models.dart';
import 'package:filmdizi/features/relationship_graph/domain/graph_path_finder.dart';

void main() {
  group('findShortestPath BFS', () {
    final titleA = GraphNode(id: 't:1', type: GraphNodeType.movie, label: 'Film A');
    final titleB = GraphNode(id: 't:2', type: GraphNodeType.movie, label: 'Film B');
    final titleC = GraphNode(id: 't:3', type: GraphNodeType.movie, label: 'Film C');
    final personX = GraphNode(id: 'p:x', type: GraphNodeType.actor, label: 'Actor X');
    final personY = GraphNode(id: 'p:y', type: GraphNodeType.director, label: 'Director Y');

    final edgeAX = const GraphEdge(sourceId: 't:1', targetId: 'p:x', type: GraphEdgeType.actedIn);
    final edgeBX = const GraphEdge(sourceId: 't:2', targetId: 'p:x', type: GraphEdgeType.actedIn);
    final edgeBY = const GraphEdge(sourceId: 't:2', targetId: 'p:y', type: GraphEdgeType.directed);
    final edgeCY = const GraphEdge(sourceId: 't:3', targetId: 'p:y', type: GraphEdgeType.directed);

    final graph = RelationshipGraph(
      nodes: [titleA, titleB, titleC, personX, personY],
      edges: [edgeAX, edgeBX, edgeBY, edgeCY],
    );

    test('finds path across multiple steps (Film A -> Actor X -> Film B -> Director Y -> Film C)', () {
      final path = findShortestPath(graph, 't:1', 't:3');

      expect(path, isNotNull);
      expect(path!.distance, 4);
      expect(path.nodeIds, ['t:1', 'p:x', 't:2', 'p:y', 't:3']);
      expect(path.edges.length, 4);
    });

    test('returns 0 distance for same node', () {
      final path = findShortestPath(graph, 't:1', 't:1');

      expect(path, isNotNull);
      expect(path!.distance, 0);
      expect(path.nodeIds, ['t:1']);
    });

    test('returns null when nodes are disconnected', () {
      final lonely = GraphNode(id: 't:99', type: GraphNodeType.movie, label: 'Isolated');
      final discGraph = RelationshipGraph(
        nodes: [...graph.nodes, lonely],
        edges: graph.edges,
      );

      final path = findShortestPath(discGraph, 't:1', 't:99');
      expect(path, isNull);
    });
  });
}
