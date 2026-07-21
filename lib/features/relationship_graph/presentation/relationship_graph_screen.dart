import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../actor_profile/presentation/actor_profile_screen.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../domain/force_directed_layout.dart';
import '../domain/graph_models.dart';
import 'relationship_graph_provider.dart';
import 'widgets/graph_canvas.dart';
import 'widgets/graph_empty_state.dart';
import 'widgets/graph_filter_bar.dart';
import 'widgets/graph_inspector_panel.dart';
import 'widgets/graph_mini_map.dart';
import 'widgets/graph_toolbar.dart';

/// İlişki Ağı — the interactive node graph of the user's watched titles linked
/// by shared actors/directors. Derives its data from [relationshipGraphProvider]
/// and lays it out once (deterministically) per graph, then hosts the pan/zoom
/// canvas plus the toolbar, filter bar, inspector and minimap overlays.
class RelationshipGraphScreen extends ConsumerStatefulWidget {
  const RelationshipGraphScreen({super.key});

  @override
  ConsumerState<RelationshipGraphScreen> createState() =>
      _RelationshipGraphScreenState();
}

class _RelationshipGraphScreenState
    extends ConsumerState<RelationshipGraphScreen> {
  final TransformationController _controller = TransformationController();

  RelationshipGraph? _laidOut; // identity of the graph currently laid out
  Size _contentSize = const Size(1, 1);
  Size _viewport = Size.zero;
  bool _didInitialFit = false;

  String? _selectedId;
  bool _showActors = true;
  bool _showDirectors = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGraph = ref.watch(relationshipGraphProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: asyncGraph.when(
          // Keep the current graph on screen while a records change refetches
          // credits, instead of flashing back to the spinner.
          skipLoadingOnReload: true,
          data: _body,
          loading: _loading,
          error: (_, _) => _errorState(),
        ),
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
          SizedBox(height: 16),
          Text('Bağlantılar analiz ediliyor…',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _errorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Bağlantılar yüklenemedi. İnternet bağlantını kontrol edip tekrar dene.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _body(RelationshipGraph graph) {
    if (!graph.hasConnections) return const GraphEmptyState();

    // Lay out once per distinct graph instance (the provider only returns a
    // new instance when watch records change).
    if (!identical(graph, _laidOut)) {
      _contentSize = computeForceDirectedLayout(graph);
      _laidOut = graph;
      _didInitialFit = false;
      _selectedId = null;
    }

    // Apply filters → visible edges/nodes.
    final byId = graph.nodesById;
    bool personVisible(GraphNode n) =>
        (n.type == GraphNodeType.actor && _showActors) ||
        (n.type == GraphNodeType.director && _showDirectors);
    final visibleEdges = graph.edges.where((e) {
      final target = byId[e.targetId];
      if (target == null || !personVisible(target)) return false;
      if (e.type == GraphEdgeType.actedIn) return _showActors;
      if (e.type == GraphEdgeType.directed) return _showDirectors;
      return true;
    }).toList();
    final visibleNodeIds = <String>{};
    for (final e in visibleEdges) {
      visibleNodeIds
        ..add(e.sourceId)
        ..add(e.targetId);
    }

    // Focus highlight set.
    final highlightIds = <String>{};
    if (_selectedId != null) {
      highlightIds.add(_selectedId!);
      for (final e in visibleEdges) {
        if (e.sourceId == _selectedId) highlightIds.add(e.targetId);
        if (e.targetId == _selectedId) highlightIds.add(e.sourceId);
      }
    }

    final selectedNode =
        _selectedId == null ? null : byId[_selectedId!];

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        if (!_didInitialFit && _viewport.width > 0) {
          _didInitialFit = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fitToContent();
          });
        }
        final panelWidth = math.min(280.0, _viewport.width - 24);

        return Stack(
          children: [
            Positioned.fill(
              child: GraphCanvas(
                graph: graph,
                contentSize: _contentSize,
                controller: _controller,
                visibleNodeIds: visibleNodeIds,
                visibleEdges: visibleEdges,
                selectedId: _selectedId,
                highlightIds: highlightIds,
                onSelect: (id) => setState(() => _selectedId = id),
                onNavigate: _navigateTo,
              ),
            ),

            // Toolbar.
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: GraphToolbar(
                titleCount: visibleNodeIds
                    .where((id) => byId[id]?.type.isTitle ?? false)
                    .length,
                personCount: visibleNodeIds
                    .where((id) => byId[id]?.type.isPerson ?? false)
                    .length,
                onSearch: _onSearch,
                onFit: _fitToContent,
              ),
            ),

            // Filter bar.
            Positioned(
              top: 84,
              left: 12,
              child: GraphFilterBar(
                showActors: _showActors,
                showDirectors: _showDirectors,
                onActorsChanged: (v) => setState(() => _showActors = v),
                onDirectorsChanged: (v) => setState(() => _showDirectors = v),
              ),
            ),

            // Minimap.
            Positioned(
              left: 12,
              bottom: 12,
              child: GraphMiniMap(
                graph: graph,
                visibleNodeIds: visibleNodeIds,
                contentSize: _contentSize,
                viewportSize: _viewport,
                controller: _controller,
              ),
            ),

            // Inspector panel.
            Positioned(
              top: 84,
              right: 12,
              bottom: 12,
              width: panelWidth,
              child: IgnorePointer(
                ignoring: selectedNode == null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                              begin: const Offset(0.15, 0), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: selectedNode == null
                      ? const SizedBox.shrink()
                      : Align(
                          key: ValueKey(selectedNode.id),
                          alignment: Alignment.topRight,
                          child: GraphInspectorPanel(
                            node: selectedNode,
                            graph: graph,
                            onSelectNeighbor: (id) {
                              setState(() => _selectedId = id);
                              final n = byId[id];
                              if (n != null) _centerOn(n, scale: 1.0);
                            },
                            onOpenDetail: _navigateTo,
                            onClose: () => setState(() => _selectedId = null),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _fitToContent() {
    if (_viewport.width <= 0) return;
    // Fit the whole graph, but never below the readable floor — a very large
    // graph opens centered at a comfortable zoom instead of a tiny speck-cloud
    // (the user can pan/zoom-out from there). The 0.9 leaves a breathing
    // margin so nodes don't touch the edges.
    final s = (0.9 *
            math.min(_viewport.width / _contentSize.width,
                _viewport.height / _contentSize.height))
        .clamp(0.5, 1.2)
        .toDouble();
    final dx = (_viewport.width - _contentSize.width * s) / 2;
    final dy = (_viewport.height - _contentSize.height * s) / 2;
    _controller.value = _transform(dx, dy, s);
  }

  void _centerOn(GraphNode node, {double scale = 1.0}) {
    if (_viewport.width <= 0) return;
    final tx = _viewport.width / 2 - node.position.dx * scale;
    final ty = _viewport.height / 2 - node.position.dy * scale;
    _controller.value = _transform(tx, ty, scale);
  }

  /// Pan-then-scale transform for the [InteractiveViewer], built with the
  /// non-deprecated Matrix4 helpers.
  Matrix4 _transform(double tx, double ty, double s) => Matrix4.identity()
    ..translateByDouble(tx, ty, 0, 1)
    ..scaleByDouble(s, s, 1, 1);

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;
    final graph = _laidOut;
    if (graph == null) return;
    for (final n in graph.nodes) {
      if (n.label.toLowerCase().contains(q)) {
        setState(() => _selectedId = n.id);
        _centerOn(n, scale: 1.0);
        return;
      }
    }
  }

  Future<void> _navigateTo(GraphNode node) async {
    if (node.type.isTitle && node.tmdbId != null) {
      unawaited(Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(tmdbId: node.tmdbId!, isTv: node.isTv),
        ),
      ));
      return;
    }
    // Person node from full credits already carries the TMDb person id → open
    // the profile directly, no lookup needed.
    if (node.tmdbId != null) {
      unawaited(Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ActorProfileScreen(actorId: node.tmdbId!)),
      ));
      return;
    }
    // Fallback (offline name-based node): resolve the id from the name, same
    // pattern as movie_detail_cast_list.
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${node.label} profili aranıyor…'),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      final id = await ref.read(tmdbServiceProvider).searchPersonId(node.label);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      if (id != null) {
        unawaited(Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActorProfileScreen(actorId: id),
          ),
        ));
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('${node.label} için profil bulunamadı.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil aranırken bir hata oluştu.')),
      );
    }
  }
}
