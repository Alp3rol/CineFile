import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/map_graph.dart';

/// Collapsible overlay summarizing the map: how many "galaxies", the most
/// central person, and the most tightly linked pair. Rows are actionable.
class GraphInsightCard extends StatefulWidget {
  final MapInsights insights;
  final String Function(String titleId) titleLabel;
  final VoidCallback onOpenCentralPerson;
  final VoidCallback onFocusStrongestPair;

  const GraphInsightCard({
    super.key,
    required this.insights,
    required this.titleLabel,
    required this.onOpenCentralPerson,
    required this.onFocusStrongestPair,
  });

  @override
  State<GraphInsightCard> createState() => _GraphInsightCardState();
}

class _GraphInsightCardState extends State<GraphInsightCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final i = widget.insights;
    return GlassContainer(
      borderRadius: 18,
      opacity: 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insights_rounded,
                    size: 16, color: AppTheme.accentColor),
                const SizedBox(width: 6),
                Text('İçgörüler',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            _row(Icons.hub_rounded,
                '${i.clusterCount} evren'
                '${i.biggestCluster != null && i.biggestCluster!.label.isNotEmpty ? ' · en büyük: ${i.biggestCluster!.label}' : ''}',
                null),
            if (i.mostCentralPerson != null)
              _row(
                Icons.star_rounded,
                'En merkezi: ${i.mostCentralPerson!.name} (${i.centralPersonTitleCount} yapım)',
                widget.onOpenCentralPerson,
              ),
            if (i.strongestPair != null)
              _row(
                Icons.link_rounded,
                'En bağlı: ${widget.titleLabel(i.strongestPair!.aId)} ↔ '
                '${widget.titleLabel(i.strongestPair!.bId)} (${i.strongestPair!.weight})',
                widget.onFocusStrongestPair,
              ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textPrimary)),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(Icons.chevron_right_rounded,
                    size: 14, color: AppTheme.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
