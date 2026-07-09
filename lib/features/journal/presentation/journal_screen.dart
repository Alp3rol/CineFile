import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/movie_repository.dart';
import 'widgets/custom_lists_tab.dart';
import 'widgets/journal_filter_bar.dart';
import 'widgets/journal_record_list.dart';
import 'widgets/journal_table_list.dart';
import '../../insights/presentation/insights_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/presentation/settings_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String _searchQuery = '';
  String _activeFilter = 'all'; // all, favorites, cinema, notes
  String _sortColumn = 'personal_ranking'; // table view only
  bool _sortAscending = true;

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) return;

    // Find the latest watch record ID for each unique movie (tmdbId, isTv) (based on watchDate)
    final latestWatchIds = <MovieKey, int>{};
    final latestWatches = <MovieKey, WatchRecordWithMovie>{};
    for (final r in list) {
      final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
      final currentLatest = latestWatches[key];
      if (currentLatest == null || r.record.watchDate.isAfter(currentLatest.record.watchDate)) {
        latestWatches[key] = r;
        latestWatchIds[key] = r.record.id;
      }
    }

    final updatedList = List<WatchRecordWithMovie>.from(list);
    final movedItem = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, movedItem);

    final newRanks = <MovieKey, int?>{};

    // Find the last index of a ranked item in the list BEFORE the move, excluding the moved item.
    int lastRankedIndexBeforeMove = -1;
    for (int i = 0; i < list.length; i++) {
      final key = (tmdbId: list[i].movie.tmdbId, isTv: list[i].movie.isTv);
      final isLatest = latestWatchIds[key] == list[i].record.id;
      final rank = isLatest ? list[i].setting?.personalRanking : null;
      if (i != oldIndex && rank != null) {
        lastRankedIndexBeforeMove = i;
      }
    }

    int lastRankedBoundary = lastRankedIndexBeforeMove;
    if (lastRankedIndexBeforeMove > oldIndex) {
      lastRankedBoundary = lastRankedIndexBeforeMove - 1;
    }

    final isDroppedInRankedArea = newIndex <= (lastRankedBoundary + 1);

    int currentRank = 1;
    for (int i = 0; i < updatedList.length; i++) {
      final item = updatedList[i];
      final key = (tmdbId: item.movie.tmdbId, isTv: item.movie.isTv);
      final isLatest = latestWatchIds[key] == item.record.id;

      if (!isLatest) continue; // Only assign ranks to the latest watches to avoid setting duplicates

      if (i == newIndex) {
        if (isDroppedInRankedArea) {
          newRanks[key] = currentRank++;
        } else {
          newRanks[key] = null; // Unranked
        }
      } else {
        final wasRanked = item.setting?.personalRanking != null;
        if (wasRanked) {
          if (i <= (isDroppedInRankedArea ? lastRankedBoundary + 1 : lastRankedBoundary)) {
            newRanks[key] = currentRank++;
          } else {
            newRanks[key] = null;
          }
        } else {
          newRanks[key] = null;
        }
      }
    }

    await _updateRankingsInDatabase(newRanks);
  }

  @override
  Widget build(BuildContext context) {
    final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
    final favoriteIdsAsync = ref.watch(favoriteMovieIdsProvider);
    final isTableView = ref.watch(journalViewModeProvider);

    final favorites = favoriteIdsAsync.value ?? {};

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Title Banner
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Günlüğüm',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchScreen()),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Custom styled sliding TabBar (Responsive: scrolls on mobile, fills on desktop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TabBar(
                  isScrollable: MediaQuery.of(context).size.width < 500,
                  tabAlignment: MediaQuery.of(context).size.width < 500 ? TabAlignment.start : TabAlignment.fill,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.accentColor,
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.normal, fontSize: 12),
                  tabs: const [
                    Tab(text: 'İzleme Günlüğü'),
                    Tab(text: 'Özel Listeler'),
                    Tab(text: 'Analiz & İstatistik'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: İzleme Günlüğü
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Search Field Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Günlük içinde ara (Film, yönetmen, not, mekan...)...',
                              hintStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),

                        // 3. Quick Filter Chips Bar + View Mode Toggle
                        Row(
                          children: [
                            Expanded(
                              child: JournalFiltersBar(
                                activeFilter: _activeFilter,
                                onFilterChanged: (key) => setState(() => _activeFilter = key),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildViewModeToggle(isTableView),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 4. Table Body Logic & Calculations
                        Expanded(
                          child: watchRecordsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                            error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
                            data: (records) {
                              if (records.isEmpty) {
                                return _buildEmptyState();
                              }

                              // Apply Filter: Favorites
                              var filtered = records;
                              if (_activeFilter == 'favorites') {
                                filtered = filtered
                                    .where((r) => favorites.contains((tmdbId: r.movie.tmdbId, isTv: r.movie.isTv)))
                                    .toList();
                              }
                              // Filter: Cinema
                              else if (_activeFilter == 'cinema') {
                                filtered = filtered.where((r) => r.record.watchPlace?.toLowerCase().contains('sinema') ?? false).toList();
                              }
                              // Filter: With Notes
                              else if (_activeFilter == 'notes') {
                                filtered = filtered.where((r) => r.record.notes != null && r.record.notes!.trim().isNotEmpty).toList();
                              }

                              // Filter: Search Query
                              if (_searchQuery.isNotEmpty) {
                                filtered = filtered.where((r) {
                                  final title = r.movie.title.toLowerCase();
                                  final dir = r.movie.director?.toLowerCase() ?? '';
                                  final actor = r.movie.actors?.toLowerCase() ?? '';
                                  final note = r.record.notes?.toLowerCase() ?? '';
                                  final place = r.record.watchPlace?.toLowerCase() ?? '';
                                  final comp = r.record.watchCompanion?.toLowerCase() ?? '';
                                  final tags = r.record.tags?.toLowerCase() ?? '';
                                  return title.contains(_searchQuery) ||
                                      dir.contains(_searchQuery) ||
                                      actor.contains(_searchQuery) ||
                                      note.contains(_searchQuery) ||
                                      place.contains(_searchQuery) ||
                                      comp.contains(_searchQuery) ||
                                      tags.contains(_searchQuery);
                                }).toList();
                              }

                              // --- CALCULATE INSIGHTS STATS ---
                              final now = DateTime.now();
                              final thisMonthCount = filtered.where((r) => r.record.watchDate.year == now.year && r.record.watchDate.month == now.month).length;

                              double avgRating = 0.0;
                              if (filtered.isNotEmpty) {
                                final totalRating = filtered.map((r) => r.record.rating).reduce((a, b) => a + b);
                                avgRating = totalRating / filtered.length;
                              }

                              int totalRuntimeMinutes = 0;
                              for (final item in filtered) {
                                totalRuntimeMinutes += (item.movie.runtime ?? 0) * item.record.episodeCount;
                              }
                              final totalHours = totalRuntimeMinutes ~/ 60;
                              final totalRemainingMinutes = totalRuntimeMinutes % 60;

                              String favoriteGenre = 'Belirsiz';
                              if (filtered.isNotEmpty) {
                                final genreCounts = <String, int>{};
                                for (final item in filtered) {
                                  final genresList = item.movie.genres?.split(', ') ?? [];
                                  for (final g in genresList) {
                                    if (g.trim().isNotEmpty) {
                                      genreCounts[g] = (genreCounts[g] ?? 0) + 1;
                                    }
                                  }
                                }
                                if (genreCounts.isNotEmpty) {
                                  final sortedGenres = genreCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                                  favoriteGenre = sortedGenres.first.key;
                                }
                              }

                              // Table view sorting (personal ranking / title / rating / date)
              if (isTableView) {
                                final latestWatchIds = <MovieKey, int>{};
                                final latestWatches = <MovieKey, WatchRecordWithMovie>{};
                                for (final r in filtered) {
                                  final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
                                  final currentLatest = latestWatches[key];
                                  if (currentLatest == null || r.record.watchDate.isAfter(currentLatest.record.watchDate)) {
                                    latestWatches[key] = r;
                                    latestWatchIds[key] = r.record.id;
                                  }
                                }
                                filtered.sort((a, b) {
                                  if (_sortColumn == 'title') {
                                    final cmp = a.movie.title.compareTo(b.movie.title);
                                    return _sortAscending ? cmp : -cmp;
                                  } else if (_sortColumn == 'rating') {
                                    final cmp = a.record.rating.compareTo(b.record.rating);
                                    return _sortAscending ? cmp : -cmp;
                                  } else if (_sortColumn == 'date') {
                                    final cmp = a.record.watchDate.compareTo(b.record.watchDate);
                                    return _sortAscending ? cmp : -cmp;
                                  } else {
                                    // personal_ranking (default)
                                    final isLatestA =
                                        latestWatchIds[(tmdbId: a.movie.tmdbId, isTv: a.movie.isTv)] == a.record.id;
                                    final isLatestB =
                                        latestWatchIds[(tmdbId: b.movie.tmdbId, isTv: b.movie.isTv)] == b.record.id;

                                    final rankA = isLatestA ? a.setting?.personalRanking : null;
                                    final rankB = isLatestB ? b.setting?.personalRanking : null;

                                    if (rankA != null && rankB != null) {
                                      final cmp = rankA.compareTo(rankB);
                                      return _sortAscending ? cmp : -cmp;
                                    } else if (rankA != null) {
                                      return _sortAscending ? -1 : 1;
                                    } else if (rankB != null) {
                                      return _sortAscending ? 1 : -1;
                                    } else {
                                      return b.record.watchDate.compareTo(a.record.watchDate);
                                    }
                                  }
                                });
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // v0.6.1: Dinamik Mini İstatistik Barı
                                  JournalMiniInsightsBar(
                                    thisMonthCount: thisMonthCount,
                                    avgRating: avgRating,
                                    favoriteGenre: favoriteGenre,
                                    totalHours: totalHours,
                                    totalMinutes: totalRemainingMinutes,
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
                                              JournalHeaderCell(label: 'Sıra', columnKey: 'personal_ranking', flex: 1, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                              JournalHeaderCell(label: 'Film Adı', columnKey: 'title', flex: isMobile ? 4 : 3, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                              JournalHeaderCell(label: isMobile ? 'İzleme' : 'İzleme Tarihi', columnKey: 'date', flex: isMobile ? 3 : 2, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                              if (!isMobile)
                                                JournalHeaderCell(label: 'İzleme Sırası', columnKey: 'watch_count', flex: 2, sortable: false, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                              JournalHeaderCell(label: 'Puanım', columnKey: 'rating', flex: 2, activeSortColumn: _sortColumn, sortAscending: _sortAscending, onSort: _onSort),
                                            ],
                                          ),
                                        );
                                      }
                                    ),
                                    const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                                    Expanded(
                                      child: JournalRecordsTable(
                                        items: filtered,
                                        onReorder: _onReorder,
                                        onUpdateRanking: _updateRankingsInDatabase,
                                      ),
                                    ),
                                  ] else
                                    // Month-grouped record cards
                                    Expanded(
                                      child: JournalRecordsList(
                                        items: filtered,
                                        onUpdateRanking: _updateRankingsInDatabase,
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
                                                'Bu listedeki filmleri izlemek için toplam $totalHours Saat $totalRemainingMinutes Dakika harcadınız.',
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
                    const CustomListsTab(),

                    // Tab 3: Analiz & İstatistik
                    const InsightsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card view / table view switcher
  Widget _buildViewModeToggle(bool isTableView) {
    Widget buildOption({required bool selected, required IconData icon, required bool value}) {
      return GestureDetector(
        onTap: () => ref.read(journalViewModeProvider.notifier).setTableView(value),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: selected ? Colors.white : AppTheme.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          buildOption(selected: !isTableView, icon: Icons.view_agenda_rounded, value: false),
          buildOption(selected: isTableView, icon: Icons.table_rows_rounded, value: true),
        ],
      ),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _activeFilter != 'all' ? Icons.search_off_rounded : Icons.menu_book_rounded,
            size: 56,
            color: AppTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Kayıt Bulunamadı',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Text(
              _activeFilter != 'all' || _searchQuery.isNotEmpty
                  ? 'Arama kriterlerinize veya filtrelere uyan bir günlük kaydı bulunmamaktadır.'
                  : 'Günlüğünüz henüz boş. Keşfet sekmesinden yeni izleme kayıtları ekleyebilirsiniz.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
