import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';

/// Top toolbar: a title, a search field that jumps to a matching node, and a
/// "fit to screen" action that recenters the whole graph.
class GraphToolbar extends StatelessWidget {
  final int titleCount;
  final int personCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onFit;

  const GraphToolbar({
    super.key,
    required this.titleCount,
    required this.personCount,
    required this.onSearch,
    required this.onFit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      opacity: 0.75,
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('İlişki Ağı',
                    style: Theme.of(context).textTheme.titleLarge),
                Text('$titleCount yapım · $personCount köprü',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 38,
            child: TextField(
              onChanged: onSearch,
              onSubmitted: onSearch,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Ara…',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 34, minHeight: 34),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor: AppTheme.backgroundColor.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Ekrana sığdır',
            onPressed: onFit,
            icon: const Icon(Icons.fit_screen_rounded,
                color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
