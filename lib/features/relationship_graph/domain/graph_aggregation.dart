import '../../../core/database/app_database.dart';
import 'graph_models.dart';
import 'graph_overrides.dart';

/// A person aggregated across the user's watched titles, after the prominence
/// filter and manual overrides are applied. Shared by both the person-mediated
/// graph ([buildCuratedGraph]) and the clustered map ([buildMapGraph]) so the
/// two views always agree on who connects what.
class PersonAggregation {
  final String key; // 'id:<tmdbId>' or 'nm:<normalized name>'
  final String displayName;
  final int? id;
  String? profilePath;

  /// titleId → the role this person plays in that title (director outranks).
  final Map<String, GraphEdgeType> titleRoles = {};
  bool directedAny = false;
  bool actedAny = false;

  PersonAggregation(this.key, this.displayName, this.id, this.profilePath);

  /// Number of distinct titles this person connects.
  int get degree => titleRoles.length;
}

/// Builds the person aggregation for [titles] from [creditsByTitle], applying:
/// prominence at [depth] (unless the person is promoted by a manual add),
/// per-title manual adds/removes, and the global hidden set.
Map<String, PersonAggregation> aggregatePeople(
  Map<String, Movie> titles,
  Map<String, List<CreditPerson>> creditsByTitle,
  GraphOverrides overrides,
  CastDepth depth,
) {
  final promoted = overrides.promotedKeys;
  final people = <String, PersonAggregation>{};

  void ingest(String titleId, CreditPerson p) {
    final key = personKey(p);
    if (key == 'nm:') return;
    final agg = people.putIfAbsent(
      key,
      () => PersonAggregation(key, p.name, p.id, p.profilePath),
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
  return people;
}
