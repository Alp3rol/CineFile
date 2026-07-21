import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// A small overview of the whole graph with the current viewport drawn as a
/// rectangle, so the user keeps their bearings when zoomed in. Passive (no
/// interaction) in v1.
class GraphMiniMap extends StatefulWidget {
  final RelationshipGraph graph;
  final Set<String> visibleNodeIds;
  final Size contentSize;
  final Size viewportSize;
  final TransformationController controller;

  const GraphMiniMap({
    super.key,
    required this.graph,
    required this.visibleNodeIds,
    required this.contentSize,
    required this.viewportSize,
    required this.controller,
  });

  @override
  State<GraphMiniMap> createState() => _GraphMiniMapState();
}

class _GraphMiniMapState extends State<GraphMiniMap> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const box = Size(128, 96);
    return Container(
      width: box.width,
      height: box.height,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _MiniMapPainter(
          graph: widget.graph,
          visibleNodeIds: widget.visibleNodeIds,
          contentSize: widget.contentSize,
          viewportSize: widget.viewportSize,
          controller: widget.controller,
          box: box,
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final RelationshipGraph graph;
  final Set<String> visibleNodeIds;
  final Size contentSize;
  final Size viewportSize;
  final TransformationController controller;
  final Size box;

  _MiniMapPainter({
    required this.graph,
    required this.visibleNodeIds,
    required this.contentSize,
    required this.viewportSize,
    required this.controller,
    required this.box,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & box);

    final scale = math.min(
        box.width / contentSize.width, box.height / contentSize.height);
    final ox = (box.width - contentSize.width * scale) / 2;
    final oy = (box.height - contentSize.height * scale) / 2;

    for (final n in graph.nodes) {
      if (!visibleNodeIds.contains(n.id)) continue;
      final p = Offset(ox + n.position.dx * scale, oy + n.position.dy * scale);
      canvas.drawCircle(
        p,
        n.type.isTitle ? 1.6 : 1.1,
        Paint()..color = GraphStyle.colorFor(n.type).withValues(alpha: 0.9),
      );
    }

    // Viewport rectangle: map the screen corners back into content space.
    final topLeft = controller.toScene(Offset.zero);
    final bottomRight =
        controller.toScene(Offset(viewportSize.width, viewportSize.height));
    final rect = Rect.fromLTRB(
      ox + topLeft.dx * scale,
      oy + topLeft.dy * scale,
      ox + bottomRight.dx * scale,
      oy + bottomRight.dy * scale,
    );
    // Draw viewport fill
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppTheme.accentColor.withValues(alpha: 0.12),
    );
    // Draw viewport border
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppTheme.accentColor.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter old) => true;
}
