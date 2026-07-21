import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// Slide-in detail panel for the selected node. Lists the node's direct
/// relationships (tap one to jump to it) and offers a deep link into the
/// existing MovieDetail / ActorProfile screens.
class GraphInspectorPanel extends StatelessWidget {
  final GraphNode node;
  final RelationshipGraph graph;
  final ValueChanged<String> onSelectNeighbor;
  final ValueChanged<GraphNode> onOpenDetail;
  final VoidCallback onClose;

  /// Curation callbacks (İlişki Ağı kişiselleştirme).
  final VoidCallback onAddPerson; // title node → open add-person sheet
  final VoidCallback onHidePerson; // person node → hide globally
  final ValueChanged<GraphNode> onRemoveNeighbor; // remove a neighbor link

  const GraphInspectorPanel({
    super.key,
    required this.node,
    required this.graph,
    required this.onSelectNeighbor,
    required this.onOpenDetail,
    required this.onClose,
    required this.onAddPerson,
    required this.onHidePerson,
    required this.onRemoveNeighbor,
  });

  @override
  Widget build(BuildContext context) {
    final color = GraphStyle.colorFor(node.type);
    final neighbors = _neighbors();

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.85,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(GraphStyle.iconFor(node.type), size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(GraphStyle.labelFor(node.type),
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    size: 20, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node.type.isTitle)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 46,
                    height: 66,
                    child: AppNetworkImage(
                        imageUrl: node.imageUrl ?? '', seed: node.label),
                  ),
                )
              else
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(GraphStyle.iconFor(node.type), color: color),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.label,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      node.type.isTitle
                          ? '${neighbors.length} ortak kişi ile bağlı'
                          : '${neighbors.length} yapımı birbirine bağlıyor',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: neighbors.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _neighborTile(neighbors[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Curation action (title → Kişi Ekle, person → Grafta Gizle).
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: node.type.isTitle ? onAddPerson : onHidePerson,
              icon: Icon(
                  node.type.isTitle
                      ? Icons.person_add_alt_1_rounded
                      : Icons.visibility_off_rounded,
                  size: 18),
              label: Text(node.type.isTitle ? 'Kişi Ekle' : 'Grafta Gizle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.borderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onOpenDetail(node),
              icon: Icon(
                  node.type.isTitle
                      ? Icons.open_in_new_rounded
                      : Icons.person_search_rounded,
                  size: 18),
              label: Text(node.type.isTitle ? 'Detaya git' : 'Profili aç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.18),
                foregroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _neighborTile(GraphNode n) {
    final color = GraphStyle.colorFor(n.type);
    return GestureDetector(
      onTap: () => onSelectNeighbor(n.id),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(GraphStyle.iconFor(n.type), size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(n.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary)),
          ),
          // Remove this specific link (person↔title). Tooltip clarifies scope.
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Bu bağlantıyı kaldır',
            onPressed: () => onRemoveNeighbor(n),
            icon: const Icon(Icons.close_rounded,
                size: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<GraphNode> _neighbors() {
    final byId = graph.nodesById;
    final result = <GraphNode>[];
    final seen = <String>{};
    for (final e in graph.edges) {
      String? otherId;
      if (e.sourceId == node.id) {
        otherId = e.targetId;
      } else if (e.targetId == node.id) {
        otherId = e.sourceId;
      }
      if (otherId == null || !seen.add(otherId)) continue;
      final other = byId[otherId];
      if (other != null) result.add(other);
    }
    return result;
  }
}
