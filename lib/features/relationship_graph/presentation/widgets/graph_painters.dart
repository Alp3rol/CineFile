import 'package:flutter/material.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// Blueprint-style grid drawn inside the transformed canvas child, so it scales
/// and pans together with the nodes (a real infinite-canvas feel) rather than
/// staying pinned to the screen.
class GraphGridPainter extends CustomPainter {
  const GraphGridPainter();

  static const double _minor = 40;
  static const double _major = 200;

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += _minor) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height),
          x % _major == 0 ? majorPaint : minorPaint);
    }
    for (double y = 0; y <= size.height; y += _minor) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          y % _major == 0 ? majorPaint : minorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GraphGridPainter oldDelegate) => false;
}

/// Draws the edges as cubic bezier curves between node centers. When a node is
/// selected, edges touching it are highlighted and all others fade back, giving
/// the "focus" effect. Edge color encodes the relationship (actor vs director);
/// thickness scales gently with the bridging person's degree.
class GraphEdgePainter extends CustomPainter {
  final List<GraphEdge> edges;
  final Map<String, GraphNode> nodesById;
  final String? selectedId;

  /// Ids that should stay fully lit (selected node + its neighbors). Empty when
  /// nothing is selected, meaning "draw everything at normal emphasis".
  final Set<String> highlightIds;

  /// Bumped by the host on drag so the painter repaints as positions mutate.
  GraphEdgePainter({
    required this.edges,
    required this.nodesById,
    required this.selectedId,
    required this.highlightIds,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final hasFocus = selectedId != null;
    for (final e in edges) {
      final a = nodesById[e.sourceId];
      final b = nodesById[e.targetId];
      if (a == null || b == null) continue;

      final lit = !hasFocus ||
          (highlightIds.contains(e.sourceId) &&
              highlightIds.contains(e.targetId));

      final base = GraphStyle.edgeColor(e.type);
      final degree = b.degree; // person node degree
      final width = (1.2 + (degree - 2).clamp(0, 8) * 0.35);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = base.withValues(alpha: lit ? 0.8 : 0.06)
        ..strokeWidth = lit ? width : 1;

      final p1 = a.position;
      final p2 = b.position;
      final dx = (p2.dx - p1.dx) * 0.5;
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(p1.dx + dx, p1.dy, p2.dx - dx, p2.dy, p2.dx, p2.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GraphEdgePainter old) =>
      old.selectedId != selectedId ||
      old.edges != edges ||
      old.highlightIds != highlightIds;
}
