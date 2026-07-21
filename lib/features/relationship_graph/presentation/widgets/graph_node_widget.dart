import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// The rendered size of a node's primary shape (card for titles, disc for
/// people). Its center is anchored at [GraphNode.position], so the host places
/// it with `left: pos.dx - size.width/2, top: pos.dy - size.height/2` and edges
/// connect to the same center point.
Size graphNodeSize(GraphNode node) {
  if (node.type.isTitle) return const Size(128, 56);
  final d = 40 + (node.degree.clamp(2, 14) - 2) * 3.0; // 40..76
  return Size(d, d);
}

class GraphNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool selected;

  /// True when a *different* node is focused, so this one recedes.
  final bool dimmed;

  /// LOD: hide labels (and shrink detail) when zoomed far out.
  final bool showLabel;

  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragStart;

  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.selected,
    required this.dimmed,
    required this.showLabel,
    required this.onTap,
    required this.onDoubleTap,
    required this.onDragUpdate,
    required this.onDragStart,
  });

  @override
  Widget build(BuildContext context) {
    final size = graphNodeSize(node);
    final color = GraphStyle.colorFor(node.type);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: dimmed ? 0.22 : 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onPanStart: (_) => onDragStart(),
        onPanUpdate: (d) => onDragUpdate(d.delta),
        child: SizedBox(
          width: size.width,
          height: size.height,
          // Clip.none lets the label overflow below the shape without being
          // clipped to the shape's own box.
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              node.type.isTitle
                  ? _titleShape(size, color)
                  : _personShape(size, color),
              if (showLabel)
                Positioned(
                  top: size.height + 3,
                  child: _label(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleShape(Size size, Color color) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.55),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: size.height,
            child: AppNetworkImage(
              imageUrl: node.imageUrl ?? '',
              seed: node.label,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(GraphStyle.iconFor(node.type), size: 12, color: color),
                  const SizedBox(height: 2),
                  Text(
                    node.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.05,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personShape(Size size, Color color) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceColor,
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.7),
          width: selected ? 3 : 2,
        ),
        boxShadow: selected
            ? [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 16)]
            : [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: (node.imageUrl != null && node.imageUrl!.isNotEmpty)
          ? AppNetworkImage(
              imageUrl: node.imageUrl!,
              seed: node.label,
              fit: BoxFit.cover,
              errorWidget: Center(
                child: Icon(GraphStyle.iconFor(node.type),
                    size: size.width * 0.42, color: color),
              ),
            )
          : Center(
              child: Icon(GraphStyle.iconFor(node.type),
                  size: size.width * 0.42, color: color),
            ),
    );
  }

  Widget _label(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        node.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
