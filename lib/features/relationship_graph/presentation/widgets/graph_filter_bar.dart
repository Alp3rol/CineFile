import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/graph_models.dart';
import 'graph_style.dart';

/// Toggle chips for the relationship types shown on the canvas. v1 exposes
/// Oyuncular (actors) and Yönetmenler (directors); the reserved types slot in
/// here the same way in v2.
class GraphFilterBar extends StatelessWidget {
  final bool showActors;
  final bool showDirectors;
  final ValueChanged<bool> onActorsChanged;
  final ValueChanged<bool> onDirectorsChanged;

  const GraphFilterBar({
    super.key,
    required this.showActors,
    required this.showDirectors,
    required this.onActorsChanged,
    required this.onDirectorsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      opacity: 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(GraphNodeType.actor, 'Oyuncular', showActors, onActorsChanged),
          const SizedBox(width: 6),
          _chip(GraphNodeType.director, 'Yönetmenler', showDirectors,
              onDirectorsChanged),
        ],
      ),
    );
  }

  Widget _chip(
    GraphNodeType type,
    String label,
    bool active,
    ValueChanged<bool> onChanged,
  ) {
    final color = GraphStyle.colorFor(type);
    return GestureDetector(
      onTap: () => onChanged(!active),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? color : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
