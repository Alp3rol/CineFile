import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/graph_models.dart';

/// Top toolbar: a title, a search field that jumps to a matching node, a
/// cast-depth (kadro derinliği) selector, and a "fit to screen" action.
class GraphToolbar extends StatefulWidget {
  final int titleCount;
  final int personCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onFit;
  final VoidCallback? onResetLayout;
  final VoidCallback? onFindPath;
  final bool isLoading;
  final CastDepth depth;
  final ValueChanged<CastDepth> onDepthChanged;

  const GraphToolbar({
    super.key,
    required this.titleCount,
    required this.personCount,
    required this.onSearch,
    required this.onFit,
    this.onResetLayout,
    this.onFindPath,
    this.isLoading = false,
    required this.depth,
    required this.onDepthChanged,
  });

  @override
  State<GraphToolbar> createState() => _GraphToolbarState();
}

class _GraphToolbarState extends State<GraphToolbar> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _depthLabel(CastDepth d) => switch (d) {
        CastDepth.leads => 'Başroller',
        CastDepth.featured => 'Öne çıkanlar',
        CastDepth.all => 'Tüm kadro',
      };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 640;

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Title and subtitle area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'İlişki Ağı',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (widget.isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${widget.titleCount} yapım · ${widget.personCount} köprü',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              // Inline search box for wide screens
              if (isWide) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearch,
                    onSubmitted: widget.onSearch,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Ara…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
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
              ],

              // Action buttons
              if (!isWide)
                IconButton(
                  tooltip: 'Ara',
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isSearchExpanded
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                    color: _isSearchExpanded
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                      if (!_isSearchExpanded) {
                        _searchController.clear();
                        widget.onSearch('');
                      }
                    });
                  },
                ),

              PopupMenuButton<CastDepth>(
                tooltip: 'Kadro derinliği',
                initialValue: widget.depth,
                onSelected: widget.onDepthChanged,
                icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                itemBuilder: (context) => [
                  for (final d in CastDepth.values)
                    PopupMenuItem(
                      value: d,
                      child: Row(
                        children: [
                          Icon(
                            d == widget.depth
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: d == widget.depth
                                ? AppTheme.accentColor
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(_depthLabel(d)),
                        ],
                      ),
                    ),
                ],
              ),

              if (widget.onFindPath != null)
                IconButton(
                  tooltip: 'Bağlantı bul',
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  padding: EdgeInsets.zero,
                  onPressed: widget.onFindPath,
                  icon: const Icon(Icons.alt_route_rounded,
                      color: AppTheme.textSecondary, size: 20),
                ),

              if (widget.onResetLayout != null)
                IconButton(
                  tooltip: 'Konumları sıfırla',
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  padding: EdgeInsets.zero,
                  onPressed: widget.onResetLayout,
                  icon: const Icon(Icons.restart_alt_rounded,
                      color: AppTheme.textSecondary, size: 20),
                ),

              IconButton(
                tooltip: 'Ekrana sığdır',
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                padding: EdgeInsets.zero,
                onPressed: widget.onFit,
                icon: const Icon(Icons.fit_screen_rounded,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),

          // Expandable search bar on mobile
          if (!isWide && _isSearchExpanded) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: widget.onSearch,
                onSubmitted: widget.onSearch,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Graf içerisinde ara…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearch('');
                      setState(() => _isSearchExpanded = false);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
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
          ],
        ],
      ),
    );
  }
}
