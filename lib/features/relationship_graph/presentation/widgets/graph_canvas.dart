import 'package:flutter/material.dart';
import '../../domain/graph_models.dart';
import 'graph_node_widget.dart';
import 'graph_painters.dart';

/// The interactive canvas: an [InteractiveViewer] (pan/zoom) wrapping a fixed-
/// size [Stack] of the grid, the bezier edge layer, and one positioned widget
/// per visible node. Node dragging mutates positions in place; a repaint
/// [ValueNotifier] drives the edge painter so lines follow the dragged node.
class GraphCanvas extends StatefulWidget {
  final RelationshipGraph graph;
  final Size contentSize;
  final TransformationController controller;

  final Set<String> visibleNodeIds;
  final List<GraphEdge> visibleEdges;

  final String? selectedId;
  final Set<String> highlightIds;
  final Set<String> pathEdgeKeys;

  final ValueChanged<String?> onSelect;
  final ValueChanged<GraphNode> onNavigate;
  final ValueChanged<GraphNode> onNodeLongPress;

  const GraphCanvas({
    super.key,
    required this.graph,
    required this.contentSize,
    required this.controller,
    required this.visibleNodeIds,
    required this.visibleEdges,
    required this.selectedId,
    required this.highlightIds,
    this.pathEdgeKeys = const {},
    required this.onSelect,
    required this.onNavigate,
    required this.onNodeLongPress,
  });

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

/// Below this zoom, node labels are hidden (LOD). Kept just under the fit
/// floor so labels stay visible across the whole usable zoom range.
const double _kLabelScale = 0.42;

class _GraphCanvasState extends State<GraphCanvas> {
  final ValueNotifier<int> _repaint = ValueNotifier(0);
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTransform);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTransform);
    _repaint.dispose();
    super.dispose();
  }

  void _onTransform() {
    final s = widget.controller.value.getMaxScaleOnAxis();
    // Only rebuild when crossing the LOD threshold, not on every frame.
    final wasLabelled = _scale >= _kLabelScale;
    final isLabelled = s >= _kLabelScale;
    _scale = s;
    if (wasLabelled != isLabelled) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showLabels = _scale >= _kLabelScale;
    return InteractiveViewer(
      transformationController: widget.controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(1400),
      // Floor kept fairly high so the user can't zoom out into an unreadable
      // speck-cloud; the graph stays legible at its most-distant point.
      minScale: 0.4,
      maxScale: 3.0,
      child: GestureDetector(
        // Tapping empty canvas clears the selection/focus.
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(null),
        child: SizedBox(
          width: widget.contentSize.width,
          height: widget.contentSize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: GraphGridPainter()),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: GraphEdgePainter(
                      edges: widget.visibleEdges,
                      nodesById: widget.graph.nodesById,
                      selectedId: widget.selectedId,
                      highlightIds: widget.highlightIds,
                      pathEdgeKeys: widget.pathEdgeKeys,
                      repaint: _repaint,
                    ),
                  ),
                ),
              ),
              ..._buildNodes(showLabels),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNodes(bool showLabels) {
    final hasFocus = widget.selectedId != null;
    final widgets = <Widget>[];
    for (final node in widget.graph.nodes) {
      if (!widget.visibleNodeIds.contains(node.id)) continue;
      final size = graphNodeSize(node);
      final dimmed = hasFocus && !widget.highlightIds.contains(node.id);
      widgets.add(Positioned(
        left: node.position.dx - size.width / 2,
        top: node.position.dy - size.height / 2,
        child: GraphNodeWidget(
          key: ValueKey(node.id),
          node: node,
          selected: widget.selectedId == node.id,
          dimmed: dimmed,
          showLabel: showLabels,
          onTap: () => widget.onSelect(node.id),
          onDoubleTap: () => widget.onNavigate(node),
          onLongPress: () => widget.onNodeLongPress(node),
          onDragStart: () {
            node.pinned = true;
            if (widget.selectedId != node.id) widget.onSelect(node.id);
          },
          onDragUpdate: (delta) {
            setState(() {
              // Drag delta is in screen space; divide by scale to move the
              // node by the right amount in content space.
              node.position += delta / _scale;
              _repaint.value++;
            });
          },
        ),
      ));
    }
    return widgets;
  }
}
