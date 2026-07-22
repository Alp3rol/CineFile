import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/graph_overrides.dart';
import '../domain/map_graph.dart';
import '../domain/map_graph_builder.dart';
import 'graph_overrides_provider.dart';
import 'relationship_graph_provider.dart';

/// The clustered map ("Sinema Evrenim"). Curates cheaply over the cached raw
/// credits, so depth/override changes re-cluster instantly without refetching.
final graphMapProvider = Provider<AsyncValue<MapGraph>>((ref) {
  final rawAsync = ref.watch(rawTitleCreditsProvider);
  final overrides =
      ref.watch(graphOverridesProvider).value ?? GraphOverrides.empty;
  final depth = ref.watch(graphCastDepthProvider);
  return rawAsync
      .whenData((raw) => buildMapGraph(raw.titles, raw.credits, overrides, depth));
});
