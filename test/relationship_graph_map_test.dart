// Unit tests for the clustered map builder (v2.0): title↔title links, isolated
// titles retained, deterministic clustering, cluster labels, insights.
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/features/relationship_graph/domain/graph_models.dart';
import 'package:filmdizi/features/relationship_graph/domain/graph_overrides.dart';
import 'package:filmdizi/features/relationship_graph/domain/map_graph_builder.dart';

Movie _mv(int id, String title, {bool isTv = false, String? genres}) => Movie(
      tmdbId: id,
      title: title,
      isTv: isTv,
      genres: genres,
      runtime: 100,
      createdAt: DateTime(2024, 1, 1),
    );

CreditPerson _lead(int id, String name) =>
    CreditPerson(id: id, name: name, isDirector: false, order: 1);

String _t(int id) => 'title:$id:false';

void main() {
  group('buildMapGraph', () {
    test('two titles sharing N people → one link with weight N', () {
      final titles = {_t(1): _mv(1, 'A'), _t(2): _mv(2, 'B')};
      final credits = {
        _t(1): [_lead(1, 'X'), _lead(2, 'Y')],
        _t(2): [_lead(1, 'X'), _lead(2, 'Y')],
      };
      final g = buildMapGraph(titles, credits, GraphOverrides.empty, CastDepth.featured);
      expect(g.links.length, 1);
      expect(g.links.first.weight, 2);
      expect(g.links.first.people.map((p) => p.name).toSet(), {'X', 'Y'});
      expect(g.titles.length, 2);
    });

    test('isolated titles are retained (not dropped)', () {
      final titles = {_t(1): _mv(1, 'A'), _t(2): _mv(2, 'B'), _t(3): _mv(3, 'C')};
      final credits = {
        _t(1): [_lead(1, 'X')],
        _t(2): [_lead(1, 'X')],
        _t(3): [_lead(9, 'Lonely')], // shares nobody
      };
      final g = buildMapGraph(titles, credits, GraphOverrides.empty, CastDepth.featured);
      expect(g.titles.length, 3);
      expect(g.titles.map((t) => t.id), contains(_t(3)));
      expect(g.links.length, 1); // only A-B
    });

    test('clustering is deterministic', () {
      Map<String, Movie> titles() =>
          {for (var i = 1; i <= 4; i++) _t(i): _mv(i, 'T$i')};
      final credits = {
        _t(1): [_lead(1, 'X')],
        _t(2): [_lead(1, 'X')], // A-B cluster
        _t(3): [_lead(2, 'Y')],
        _t(4): [_lead(2, 'Y')], // C-D cluster
      };
      final g1 = buildMapGraph(titles(), credits, GraphOverrides.empty, CastDepth.featured);
      final g2 = buildMapGraph(titles(), credits, GraphOverrides.empty, CastDepth.featured);
      final c1 = {for (final t in g1.titles) t.id: t.clusterId};
      for (final t in g2.titles) {
        expect(t.clusterId, c1[t.id]);
      }
      // Two separate 2-title communities.
      expect(g1.insights.clusterCount, 2);
    });

    test('cluster label is the dominant shared person', () {
      final titles = {
        _t(1): _mv(1, 'A'),
        _t(2): _mv(2, 'B'),
        _t(3): _mv(3, 'C'),
      };
      final credits = {
        _t(1): [_lead(1, 'X'), _lead(2, 'Y')],
        _t(2): [_lead(1, 'X'), _lead(2, 'Y')],
        _t(3): [_lead(1, 'X')], // X spans 3 titles, Y only 2
      };
      final g = buildMapGraph(titles, credits, GraphOverrides.empty, CastDepth.featured);
      final big = g.clusters.firstWhere((c) => c.size >= 2);
      expect(big.label, 'X evreni');
    });

    test('insights: strongest pair and most central person', () {
      final titles = {_t(1): _mv(1, 'A'), _t(2): _mv(2, 'B'), _t(3): _mv(3, 'C')};
      final credits = {
        _t(1): [_lead(1, 'Hub'), _lead(2, 'P2'), _lead(3, 'P3')],
        _t(2): [_lead(1, 'Hub'), _lead(2, 'P2'), _lead(3, 'P3')], // A-B share 3
        _t(3): [_lead(1, 'Hub')], // Hub also in C
      };
      final g = buildMapGraph(titles, credits, GraphOverrides.empty, CastDepth.featured);
      expect(g.insights.strongestPair!.weight, 3); // A-B
      expect(g.insights.mostCentralPerson!.name, 'Hub'); // in 3 titles
      expect(g.insights.centralPersonTitleCount, 3);
    });

    test('manual add creates a link TMDb never credited', () {
      final titles = {_t(1): _mv(1, 'Son Yaz'), _t(2): _mv(2, 'Behzat')};
      final credits = {
        _t(1): [_lead(7, 'Halil Babür')],
        _t(2): <CreditPerson>[],
      };
      final overrides = GraphOverrides(perTitle: {
        _t(2): TitleOverride(
            added: [const CreditPerson(id: 7, name: 'Halil Babür', isDirector: false)]),
      });
      final g = buildMapGraph(titles, credits, overrides, CastDepth.featured);
      expect(g.links.length, 1);
      expect(g.links.first.weight, 1);
      expect(g.links.first.people.first.name, 'Halil Babür');
    });
  });
}
