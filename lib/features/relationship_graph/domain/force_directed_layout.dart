import 'dart:math' as math;
import 'package:flutter/painting.dart' show Offset, Size;
import 'graph_models.dart';

/// Deterministic Fruchterman–Reingold force-directed layout.
///
/// Runs a *bounded* number of iterations synchronously and writes final
/// positions into each [GraphNode.position]. Computing it up front (rather than
/// animating a live simulation with a repeating Ticker) keeps it deterministic
/// — required by the layout unit test — and, crucially, lets `pumpAndSettle`
/// terminate in widget tests instead of spinning forever on an endless
/// animation. [seed] fixes the initial random placement so the same graph
/// always lays out identically. [pinned] nodes are treated as fixed anchors.
///
/// Returns the content [Size] (bounding box + padding) the canvas should use.
Size computeForceDirectedLayout(
  RelationshipGraph graph, {
  int? iterations,
  int seed = 42,
  double padding = 160,
}) {
  final nodes = graph.nodes;
  final n = nodes.length;
  if (n == 0) return const Size(1, 1);
  if (n == 1) {
    nodes.first.position = Offset(padding, padding);
    return Size(padding * 2, padding * 2);
  }

  // Adaptive iteration budget: fewer passes as the graph grows, since each
  // pass is O(n²). Small graphs get a fully-settled look; large ones stay fast.
  final iters = iterations ?? (n < 60 ? 300 : (n < 200 ? 150 : 80));

  // Fixed ideal edge length so node spacing stays generous and readable no
  // matter how big the graph is.
  const k = 180.0;
  final side = k * math.sqrt(n.toDouble()) * 1.3;

  // Index lookup for edge endpoints.
  final indexOf = <String, int>{for (var i = 0; i < n; i++) nodes[i].id: i};

  // Deterministic initial placement.
  final rnd = math.Random(seed);
  final px = List<double>.filled(n, 0);
  final py = List<double>.filled(n, 0);
  for (var i = 0; i < n; i++) {
    if (nodes[i].pinned && nodes[i].position != Offset.zero) {
      px[i] = nodes[i].position.dx;
      py[i] = nodes[i].position.dy;
    } else {
      px[i] = rnd.nextDouble() * side;
      py[i] = rnd.nextDouble() * side;
    }
  }

  final dispX = List<double>.filled(n, 0);
  final dispY = List<double>.filled(n, 0);

  // Precompute edge endpoint index pairs (skip any dangling ids defensively).
  final edgePairs = <List<int>>[];
  for (final e in graph.edges) {
    final a = indexOf[e.sourceId];
    final b = indexOf[e.targetId];
    if (a != null && b != null) edgePairs.add([a, b]);
  }

  var temp = side * 0.1;
  final cooling = temp / (iters + 1);

  for (var it = 0; it < iters; it++) {
    for (var i = 0; i < n; i++) {
      dispX[i] = 0;
      dispY[i] = 0;
    }

    // Repulsion between every pair.
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        var dx = px[i] - px[j];
        var dy = py[i] - py[j];
        var dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 0.01) {
          // Deterministic tiny nudge to break exact overlaps.
          dx = (i - j).isEven ? 0.01 : -0.01;
          dy = 0.01;
          dist = 0.0141;
        }
        final force = (k * k) / dist;
        final fx = (dx / dist) * force;
        final fy = (dy / dist) * force;
        dispX[i] += fx;
        dispY[i] += fy;
        dispX[j] -= fx;
        dispY[j] -= fy;
      }
    }

    // Attraction along edges.
    for (final pair in edgePairs) {
      final a = pair[0];
      final b = pair[1];
      var dx = px[a] - px[b];
      var dy = py[a] - py[b];
      var dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 0.01) dist = 0.01;
      final force = (dist * dist) / k;
      final fx = (dx / dist) * force;
      final fy = (dy / dist) * force;
      dispX[a] -= fx;
      dispY[a] -= fy;
      dispX[b] += fx;
      dispY[b] += fy;
    }

    // Apply, capped by the cooling temperature; pinned nodes stay put.
    for (var i = 0; i < n; i++) {
      if (nodes[i].pinned) continue;
      final d = math.sqrt(dispX[i] * dispX[i] + dispY[i] * dispY[i]);
      if (d < 0.01) continue;
      final limited = math.min(d, temp);
      px[i] += (dispX[i] / d) * limited;
      py[i] += (dispY[i] / d) * limited;
    }
    temp = math.max(temp - cooling, 0.5);
  }

  // Normalize so the bounding box sits at (padding, padding).
  var minX = double.infinity, minY = double.infinity;
  var maxX = -double.infinity, maxY = -double.infinity;
  for (var i = 0; i < n; i++) {
    minX = math.min(minX, px[i]);
    minY = math.min(minY, py[i]);
    maxX = math.max(maxX, px[i]);
    maxY = math.max(maxY, py[i]);
  }
  for (var i = 0; i < n; i++) {
    nodes[i].position = Offset(px[i] - minX + padding, py[i] - minY + padding);
  }

  return Size(
    (maxX - minX) + padding * 2,
    (maxY - minY) + padding * 2,
  );
}
