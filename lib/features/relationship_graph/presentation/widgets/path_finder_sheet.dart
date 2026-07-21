import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/graph_models.dart';
import '../../domain/graph_path_finder.dart';

/// Modal bottom sheet for picking two nodes and computing the shortest path
/// (the "Kevin Bacon / 6 Degrees" connection bridge).
class PathFinderSheet extends StatefulWidget {
  final RelationshipGraph graph;
  final ValueChanged<GraphPathResult?> onPathFound;

  const PathFinderSheet({
    super.key,
    required this.graph,
    required this.onPathFound,
  });

  static void show(
    BuildContext context, {
    required RelationshipGraph graph,
    required ValueChanged<GraphPathResult?> onPathFound,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PathFinderSheet(
        graph: graph,
        onPathFound: onPathFound,
      ),
    );
  }

  @override
  State<PathFinderSheet> createState() => _PathFinderSheetState();
}

class _PathFinderSheetState extends State<PathFinderSheet> {
  String? _startId;
  String? _targetId;

  @override
  Widget build(BuildContext context) {
    final nodes = widget.graph.nodes.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    final canCalculate =
        _startId != null && _targetId != null && _startId != _targetId;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
              const Icon(Icons.alt_route_rounded, color: AppTheme.accentColor),
              const SizedBox(width: 10),
              Text(
                'Bağlantı Köprüsü Bul (6 Derece)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Seçeceğin iki yapım veya kişi arasındaki en kısa ortak oyuncu/yönetmen zincirini bulur.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Start node dropdown
          DropdownButtonFormField<String>(
            initialValue: _startId,
            dropdownColor: AppTheme.surfaceColor,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: '1. Başlangıç (Yapım veya Kişi)',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.backgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
            ),
            items: [
              for (final n in nodes)
                DropdownMenuItem(
                  value: n.id,
                  child: Text(
                    '${n.type.isTitle ? "🎬" : "👤"} ${n.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _startId = v),
          ),
          const SizedBox(height: 12),

          // Target node dropdown
          DropdownButtonFormField<String>(
            initialValue: _targetId,
            dropdownColor: AppTheme.surfaceColor,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: '2. Hedef (Yapım veya Kişi)',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.backgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
            ),
            items: [
              for (final n in nodes)
                DropdownMenuItem(
                  value: n.id,
                  child: Text(
                    '${n.type.isTitle ? "🎬" : "👤"} ${n.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _targetId = v),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: canCalculate
                  ? () {
                      final res = findShortestPath(
                          widget.graph, _startId!, _targetId!);
                      Navigator.pop(context);
                      widget.onPathFound(res);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Bağlantı Yolunu Bul',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
