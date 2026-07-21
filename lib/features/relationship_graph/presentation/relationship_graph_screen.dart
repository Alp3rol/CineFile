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
import '../domain/graph_path_finder.dart';
import 'graph_overrides_provider.dart';
import 'relationship_graph_provider.dart';
import 'screens/cine_dna_screen.dart';
import 'widgets/add_person_sheet.dart';
import 'widgets/graph_canvas.dart';
import 'widgets/graph_empty_state.dart';
import 'widgets/graph_filter_bar.dart';
import 'widgets/graph_inspector_panel.dart';
import 'widgets/graph_mini_map.dart';
import 'widgets/graph_style.dart';
import 'widgets/graph_toolbar.dart';
import 'widgets/path_finder_sheet.dart';

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
  GraphPathResult? _activePath;
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

    final pathEdgeKeys = _activePath?.edges
            .map((e) => '${e.sourceId}<->${e.targetId}')
            .toSet() ??
        const {};

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
                pathEdgeKeys: pathEdgeKeys,
                onSelect: (id) => setState(() => _selectedId = id),
                onNavigate: _navigateTo,
                onNodeLongPress: _showNodeMenu,
              ),
            ),

            // Top Overlay (Toolbar + Filter Bar).
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GraphToolbar(
                    titleCount: visibleNodeIds
                        .where((id) => byId[id]?.type.isTitle ?? false)
                        .length,
                    personCount: visibleNodeIds
                        .where((id) => byId[id]?.type.isPerson ?? false)
                        .length,
                    onSearch: _onSearch,
                    onFit: _fitToContent,
                    onResetLayout: _resetNodePositions,
                    onFindPath: () => PathFinderSheet.show(
                      context,
                      graph: graph,
                      onPathFound: _handlePathFound,
                    ),
                    onOpenDna: () => CineDnaScreen.navigate(context, graph),
                    isLoading: ref.watch(rawTitleCreditsProvider).isRefreshing,
                    depth: ref.watch(graphCastDepthProvider),
                    onDepthChanged: (d) =>
                        ref.read(graphCastDepthProvider.notifier).state = d,
                  ),
                  const SizedBox(height: 8),
                  GraphFilterBar(
                    showActors: _showActors,
                    showDirectors: _showDirectors,
                    onActorsChanged: (v) => setState(() => _showActors = v),
                    onDirectorsChanged: (v) => setState(() => _showDirectors = v),
                  ),
                ],
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
                            onAddPerson: () => _addPersonTo(selectedNode),
                            onHidePerson: () => _hidePerson(selectedNode),
                            onRemoveNeighbor: (neighbor) =>
                                _removeLink(selectedNode, neighbor),
                          ),
                        ),
                ),
              ),
            ),

            // Active Path Banner.
            if (_activePath != null)
              Positioned(
                bottom: 12,
                right: 12,
                child: Material(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.alt_route_rounded,
                            color: Color(0xFFFFC107), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_activePath!.distance} Adımda Bağlantı Bulundu',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _activePath = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handlePathFound(GraphPathResult? res) {
    setState(() => _activePath = res);
    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seçilen iki öğe arasında bağlantı bulunamadı.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

  void _resetNodePositions() {
    final graph = _laidOut;
    if (graph == null) return;
    for (final n in graph.nodes) {
      n.pinned = false;
      n.position = Offset.zero;
    }
    setState(() {
      _contentSize = computeForceDirectedLayout(graph);
      _fitToContent();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Düğüm konumları otomatik dizilime sıfırlandı.'),
        duration: Duration(seconds: 2),
      ),
    );
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

  // --- Kişisel kürasyon ---

  /// The stable person key encoded in a person node's id (`'person:<key>'`).
  String _personKeyOf(GraphNode personNode) => personNode.id.startsWith('person:')
      ? personNode.id.substring('person:'.length)
      : personNode.id;

  void _addPersonTo(GraphNode titleNode) {
    if (!titleNode.type.isTitle || titleNode.tmdbId == null) return;
    AddPersonSheet.show(context,
        tmdbId: titleNode.tmdbId!,
        isTv: titleNode.isTv,
        titleLabel: titleNode.label);
  }

  Future<void> _hidePerson(GraphNode personNode) async {
    if (!personNode.type.isPerson) return;
    await ref
        .read(graphOverridesControllerProvider)
        .hidePerson(_personKeyOf(personNode));
    if (mounted) setState(() => _selectedId = null);
  }

  Future<void> _removeLink(GraphNode selected, GraphNode neighbor) async {
    final title = selected.type.isTitle ? selected : neighbor;
    final person = selected.type.isPerson ? selected : neighbor;
    if (!title.type.isTitle || !person.type.isPerson || title.tmdbId == null) {
      return;
    }
    await ref
        .read(graphOverridesControllerProvider)
        .removePersonFromTitle(title.tmdbId!, title.isTv, _personKeyOf(person));
  }

  /// Long-press context menu on a node.
  void _showNodeMenu(GraphNode node) {
    setState(() => _selectedId = node.id);
    final isTitle = node.type.isTitle;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: Icon(GraphStyle.iconFor(node.type),
                  color: GraphStyle.colorFor(node.type)),
              title: Text(node.label,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(GraphStyle.labelFor(node.type)),
            ),
            const Divider(height: 1),
            if (isTitle)
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded),
                title: const Text('Kişi Ekle'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addPersonTo(node);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.visibility_off_rounded),
                title: const Text('Grafta Gizle'),
                onTap: () {
                  Navigator.pop(ctx);
                  _hidePerson(node);
                },
              ),
            ListTile(
              leading: Icon(isTitle
                  ? Icons.open_in_new_rounded
                  : Icons.person_search_rounded),
              title: Text(isTitle ? 'Detaya git' : 'Profili aç'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateTo(node);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
