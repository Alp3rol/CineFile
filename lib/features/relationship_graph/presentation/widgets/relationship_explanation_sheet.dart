import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// Modal bottom sheet that explains why two nodes (e.g. Movie <-> Person)
/// are connected in the relationship graph.
class RelationshipExplanationSheet extends StatelessWidget {
  final GraphNode titleNode;
  final GraphNode personNode;
  final GraphEdgeType edgeType;

  const RelationshipExplanationSheet({
    super.key,
    required this.titleNode,
    required this.personNode,
    required this.edgeType,
  });

  static void show(
    BuildContext context, {
    required GraphNode titleNode,
    required GraphNode personNode,
    required GraphEdgeType edgeType,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RelationshipExplanationSheet(
        titleNode: titleNode,
        personNode: personNode,
        edgeType: edgeType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDirector = edgeType == GraphEdgeType.directed;
    final roleName = isDirector ? 'Yönetmen' : 'Oyuncu';
    final roleColor = GraphStyle.colorFor(personNode.type);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.help_outline_rounded, color: roleColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Neden Bağlı?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: roleColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(GraphStyle.iconFor(titleNode.type),
                          size: 16, color: GraphStyle.colorFor(titleNode.type)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          titleNode.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward_rounded,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(GraphStyle.iconFor(personNode.type),
                          size: 16, color: roleColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          personNode.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              isDirector
                  ? '${personNode.label}, ${titleNode.label} projesine yönetmen koltuğunda imza atmıştır.'
                  : '${personNode.label}, ${titleNode.label} projesinin kadrosunda oyuncu olarak yer almaktadır.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
