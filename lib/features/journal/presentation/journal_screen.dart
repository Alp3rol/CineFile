import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/movie_repository.dart';
import 'journal_logic.dart';
import 'widgets/custom_lists_tab.dart';
import 'widgets/journal_empty_state.dart';
import 'widgets/journal_filter_bar.dart';
import 'widgets/journal_record_list.dart';
import 'widgets/journal_search_field.dart';
import 'widgets/journal_table_list.dart';
import 'widgets/journal_top_banner.dart';
import '../../insights/presentation/insights_screen.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../../../core/widgets/scroll_to_top_button.dart';


class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  final String _activeFilter = 'all'; // all, favorites, cinema, notes
  String _sortColumn = 'personal_ranking'; // table view only
  bool _sortAscending = true;
  bool _showSearch = false; // search bar toggled by search icon

  final _searchController = TextEditingController();

  late TabController _tabController;
  final ScrollController _scrollController1 = ScrollController(); // card list
  final ScrollController _scrollController2 = ScrollController(); // table view
  final ScrollController _scrollController3 = ScrollController(); // custom lists grid
  final ScrollController _scrollController4 = ScrollController(); // insights scroll
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabOrScrollChange);

    _scrollController1.addListener(_onTabOrScrollChange);
    _scrollController2.addListener(_onTabOrScrollChange);
    _scrollController3.addListener(_onTabOrScrollChange);
    _scrollController4.addListener(_onTabOrScrollChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabOrScrollChange);
    _tabController.dispose();

    _scrollController1.removeListener(_onTabOrScrollChange);
    _scrollController2.removeListener(_onTabOrScrollChange);
    _scrollController3.removeListener(_onTabOrScrollChange);
    _scrollController4.removeListener(_onTabOrScrollChange);

    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _scrollController4.dispose();

    _searchController.dispose();
    super.dispose();
  }

  void _onTabOrScrollChange() {
    if (!mounted) return;

    double offset = 0;
    final isTableView = ref.read(journalViewModeProvider);
    ScrollController? active;
    if (_tabController.index == 0) {
      active = isTableView ? _scrollController2 : _scrollController1;
    } else if (_tabController.index == 1) {
      active = _scrollController3;
    } else if (_tabController.index == 2) {
      active = _scrollController4;
    }
    // The active controller may not be attached to a scroll view yet — e.g.
    // right after the first build's post-frame callback fires, or right
    // after switching view mode/tab before the new list has laid out.
    if (active != null && active.hasClients) {
      offset = active.offset;
    }

    final show = offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }
  }

  void _scrollToTop() {
    ScrollController? activeController;
    final isTableView = ref.read(journalViewModeProvider);
    if (_tabController.index == 0) {
      activeController = isTableView ? _scrollController2 : _scrollController1;
    } else if (_tabController.index == 1) {
      activeController = _scrollController3;
    } else if (_tabController.index == 2) {
      activeController = _scrollController4;
    }

    if (activeController == null || !activeController.hasClients) return;
    activeController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }


  // Update personal ranking (editable via drag-reorder in table view or the
  // long-press preview dialog in either view).
  Future<void> _updateRankingsInDatabase(Map<MovieKey, int?> rankings) async {
    await ref.read(movieRepositoryProvider).updateWatchRecordRankings(rankings);
  }

  void _onSort(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnKey;
        _sortAscending = columnKey == 'personal_ranking' ? true : false;
      }
    });
  }

  // Handle Drag and Drop ranking changes (table view only)
  void _onReorder(List<WatchRecordWithMovie> list, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final newRanks = computeReorderedRankings(list, oldIndex, newIndex);

    try {
      await _updateRankingsInDatabase(newRanks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sıralama kaydedilemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
    final favoriteIdsAsync = ref.watch(favoriteMovieIdsProvider);
    final isTableView = ref.watch(journalViewModeProvider);

    final favorites = favoriteIdsAsync.value ?? {};

    // Register callback to sync scroll offset status after build (for view mode toggle)
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTabOrScrollChange());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JournalTopBanner(
              showSearch: _showSearch,
              isTableView: isTableView,
              onToggleSearch: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
            ),

            // Custom styled sliding TabBar (Responsive: scrolls on mobile, fills on desktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(12),
                overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.accentColor,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                tabs: const [
                  Tab(text: 'Günlük'),
                  Tab(text: 'Listeler'),
                  Tab(text: 'Analiz'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: İzleme Günlüğü
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JournalSearchField(
                        visible: _showSearch,
                        controller: _searchController,
                        query: _searchQuery,
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        onClear: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),

                      // Table Body Logic & Calculations
                      Expanded(
                        child: watchRecordsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                          error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
                          data: (records) {
                            if (records.isEmpty) {
                              return JournalEmptyState(activeFilter: _activeFilter, searchQuery: _searchQuery);
                            }

                            final filtered = filterJournalRecords(
                              records: records,
                              activeFilter: _activeFilter,
                              favorites: favorites,
                              searchQuery: _searchQuery,
                            );
                            final stats = computeJournalInsights(filtered);

                            if (isTableView) {
                              sortJournalRecordsForTableView(
                                filtered,
                                sortColumn: _sortColumn,
                                sortAscending: _sortAscending,
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // v0.6.1: Dinamik Mini İstatistik Barı
                                JournalMiniInsightsBar(
                                  thisMonthCount: stats.thisMonthCount,
                                  avgRating: stats.avgRating,
                                  favoriteGenre: stats.favoriteGenre,
                                  totalHours: stats.totalHours,
                                  totalMinutes: stats.totalRemainingMinutes,
                                ),
                                const SizedBox(height: 8),

                                if (isTableView) ...[
                                  // Column Headers (Adaptive: 4 columns on mobile, 5 on desktop)
                                  Builder(
                                    builder: (context) {
                                      final isMobile = MediaQuery.of(context).size.width < 500;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        child: Row(
                                          children: [
                                            JournalHeaderCell(label: 'Sıra', columnKey: 'personal_ranking', flex: null, width: 24, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                            JournalHeaderCell(label: 'Film Adı', columnKey: 'title', flex: 1, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                            JournalHeaderCell(label: isMobile ? 'İzleme' : 'İzleme Tarihi', columnKey: 'date', flex: null, width: isMobile ? 80 : 100, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                            if (!isMobile)
                                              JournalHeaderCell(label: 'İzleme Sırası', columnKey: 'watch_count', flex: null, width: 80, sortable: false, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                            JournalHeaderCell(label: 'Puanım', columnKey: 'rating', flex: null, width: isMobile ? 65 : 70, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                          ],
                                        ),
                                      );
                                    }
                                  ),
                                  const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                                  Expanded(
                                    child: JournalRecordsTable(
                                      items: filtered,
                                      onReorderItem: _onReorder,
                                      onUpdateRanking: _updateRankingsInDatabase,
                                      scrollController: _scrollController2,
                                    ),
                                  ),
                                ] else
                                  // Month-grouped record cards
                                  Expanded(
                                    child: JournalRecordsList(
                                      items: filtered,
                                      onUpdateRanking: _updateRankingsInDatabase,
                                      scrollController: _scrollController1,
                                    ),
                                  ),

                                // v0.6.4: Toplam Sinema Mesaisi Sayacı
                                if (filtered.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
                                    child: GlassContainer(
                                      borderRadius: 12,
                                      opacity: 0.7,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.hourglass_empty_rounded, color: AppTheme.accentColor, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Bu listedeki filmleri izlemek için toplam ${stats.totalHours} Saat ${stats.totalRemainingMinutes} Dakika harcadınız.',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 100), // Overlap spacing
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Özel Listeler
                  CustomListsTab(scrollController: _scrollController3),

                  // Tab 3: Analiz & İstatistik
                  InsightsScreen(scrollController: _scrollController4),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScrollToTopButton(
        onPressed: _scrollToTop,
        show: _showScrollToTop,
      ),
    );
  }
}
