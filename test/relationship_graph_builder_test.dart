// Unit tests for the İlişki Ağı graph builder (bridge rule, edge roles,
// isolated-title dropping, name normalization) and the force-directed layout
// engine's determinism.
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/relationship_graph/domain/graph_models.dart';
import 'package:filmdizi/features/relationship_graph/domain/force_directed_layout.dart';
import 'package:filmdizi/features/relationship_graph/presentation/relationship_graph_provider.dart';

WatchRecordWithMovie _rec(
  int id,
  String title, {
  bool isTv = false,
  String? director,
  String? actors,
}) {
  final movie = Movie(
    tmdbId: id,
    title: title,
    isTv: isTv,
    director: director,
    actors: actors,
    runtime: 100,
    createdAt: DateTime(2024, 1, 1),
  );
  final record = WatchRecord(
    id: id,
    movieId: id,
    isTv: isTv,
    watchDate: DateTime(2024, 1, id),
    rating: 8,
    watchNumber: 1,
    createdAt: DateTime(2024, 1, 1),
    episodeCount: 1,
    isPublic: false,
  );
  return WatchRecordWithMovie(record, movie);
}

void main() {
  group('buildRelationshipGraph', () {
    test('shared actor across two titles becomes a bridge node', () {
      final graph = buildRelationshipGraph([
        _rec(1, 'Son Yaz', actors: 'Ali Atay, Alperen Duymaz'),
        _rec(2, 'Doğanın Kanunu', actors: 'Ali Atay'),
      ]);

      expect(graph.hasConnections, isTrue);
      // Only Ali Atay appears in ≥2 titles → exactly one bridge person.
      expect(graph.personCount, 1);
      final person = graph.nodes.firstWhere((n) => n.type.isPerson);
      expect(person.label, 'Ali Atay');
      expect(person.degree, 2);
      // Both titles are kept because the bridge connects them.
      expect(graph.titleCount, 2);
      // Two actedIn edges, both to the person.
      expect(graph.edges.length, 2);
      expect(graph.edges.every((e) => e.type == GraphEdgeType.actedIn), isTrue);
      expect(graph.edges.every((e) => e.targetId == person.id), isTrue);
    });

    test('a person in only one title is not a bridge', () {
      final graph = buildRelationshipGraph([
        _rec(1, 'A', actors: 'Ali Atay, Solo Star'),
        _rec(2, 'B', actors: 'Ali Atay'),
      ]);
      final personLabels =
          graph.nodes.where((n) => n.type.isPerson).map((n) => n.label);
      expect(personLabels, contains('Ali Atay'));
      expect(personLabels, isNot(contains('Solo Star')));
    });

    test('isolated titles (no shared people) are dropped', () {
      final graph = buildRelationshipGraph([
        _rec(1, 'A', actors: 'Ali Atay'),
        _rec(2, 'B', actors: 'Ali Atay'),
        _rec(3, 'Island', actors: 'Nobody Else', director: 'Loner'),
      ]);
      final titleLabels =
          graph.nodes.where((n) => n.type.isTitle).map((n) => n.label);
      expect(titleLabels, containsAll(<String>['A', 'B']));
      expect(titleLabels, isNot(contains('Island')));
    });

    test('shared director produces a directed edge and director node', () {
      final graph = buildRelationshipGraph([
        _rec(1, 'D', director: 'Zeki Demirkubuz'),
        _rec(2, 'E', director: 'Zeki Demirkubuz'),
      ]);
      final person = graph.nodes.firstWhere((n) => n.type.isPerson);
      expect(person.type, GraphNodeType.director);
      expect(graph.edges.every((e) => e.type == GraphEdgeType.directed), isTrue);
    });

    test('name matching is case/whitespace insensitive', () {
      final graph = buildRelationshipGraph([
        _rec(1, 'A', actors: 'Ali Atay'),
        _rec(2, 'B', actors: '  ali   atay '),
      ]);
      expect(graph.personCount, 1);
      expect(graph.nodes.firstWhere((n) => n.type.isPerson).degree, 2);
    });

    test('movie and TV with the same tmdbId are distinct titles', () {
      final graph = buildRelationshipGraph([
        _rec(42, 'The Movie', isTv: false, actors: 'Shared Name'),
        _rec(42, 'The Show', isTv: true, actors: 'Shared Name'),
      ]);
      expect(graph.titleCount, 2);
      expect(graph.personCount, 1);
    });

    test('empty / unconnected input has no connections', () {
      expect(buildRelationshipGraph(const []).hasConnections, isFalse);
      final noShare = buildRelationshipGraph([
        _rec(1, 'A', actors: 'X'),
        _rec(2, 'B', actors: 'Y'),
      ]);
      expect(noShare.hasConnections, isFalse);
    });
  });

  group('computeForceDirectedLayout', () {
    RelationshipGraph sample() => buildRelationshipGraph([
          _rec(1, 'Son Yaz', actors: 'Ali Atay, Alperen Duymaz'),
          _rec(2, 'Doğanın Kanunu', actors: 'Ali Atay, Hakan Yılmaz'),
          _rec(3, 'Yahşi Cazibe', actors: 'Hakan Yılmaz'),
        ]);

    test('is deterministic for the same graph and seed', () {
      final g1 = sample();
      final g2 = sample();
      computeForceDirectedLayout(g1, seed: 7);
      computeForceDirectedLayout(g2, seed: 7);

      final p1 = {for (final n in g1.nodes) n.id: n.position};
      for (final n in g2.nodes) {
        expect(n.position, p1[n.id],
            reason: 'positions must match for ${n.id}');
      }
    });

    test('assigns finite, non-overlapping-ish positions', () {
      final g = sample();
      final size = computeForceDirectedLayout(g);
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
      for (final n in g.nodes) {
        expect(n.position.dx.isFinite, isTrue);
        expect(n.position.dy.isFinite, isTrue);
      }
    });
  });
}
