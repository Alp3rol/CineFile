import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class ContributionHeatmap extends StatefulWidget {
  final InsightsData insights;

  const ContributionHeatmap({super.key, required this.insights});

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  late DateTime selectedDate;
  late int selectedCount;
  late int selectedYear;
  String filterMode = 'all'; // 'all', 'movies', 'tv'

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    selectedDate = today;
    selectedCount = widget.insights.dailyWatchCounts[todayKey] ?? 0;
    selectedYear = today.year;
  }

  int get _maxYear => DateTime.now().year;

  int get _minYear {
    final years = widget.insights.dailyWatchCounts.keys.map((k) => int.parse(k.split('-').first));
    if (years.isEmpty) return _maxYear;
    return years.reduce((a, b) => a < b ? a : b);
  }

  void _changeYear(int delta) {
    final target = selectedYear + delta;
    if (target < _minYear || target > _maxYear) return;
    setState(() => selectedYear = target);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTurkish(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[month - 1];
  }

  Color _getCellColor(int count) {
    if (count == 0) return Colors.white.withOpacity(0.04);
    if (count == 1) return AppTheme.accentColor.withOpacity(0.25);
    if (count == 2) return AppTheme.accentColor.withOpacity(0.5);
    if (count == 3) return AppTheme.accentColor.withOpacity(0.75);
    return AppTheme.accentColor;
  }

  Map<String, int> _getActiveCounts() {
    if (filterMode == 'movies') return widget.insights.dailyMovieWatchCounts;
    if (filterMode == 'tv') return widget.insights.dailyTvWatchCounts;
    return widget.insights.dailyWatchCounts;
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(selectedYear, 1, 1);
    final startMonday = startDate.subtract(Duration(days: startDate.weekday - 1));
    final activeCounts = _getActiveCounts();

    // Sum only the cells that fall within the selected year (activeCounts
    // itself is all-time data, not scoped to what's currently displayed).
    int yearTotal = 0;
    for (final entry in activeCounts.entries) {
      if (int.parse(entry.key.split('-').first) == selectedYear) {
        yearTotal += entry.value;
      }
    }

    // Builds the month-label row for a given per-column stride (cell width +
    // gap), so labels stay aligned with the grid at any screen size.
    List<Widget> buildMonthLabels(double columnStride) {
      final labels = <Widget>[];
      String? lastMonthName;
      for (int w = 0; w < 53; w++) {
        final colDate = startMonday.add(Duration(days: w * 7));
        final monthName = _getMonthName(colDate.month);
        if (lastMonthName != monthName) {
          labels.add(
            SizedBox(
              width: columnStride * 4, // roughly a month's worth of columns
              child: Text(
                monthName,
                style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          );
          lastMonthName = monthName;
          w += 3; // skip
        } else {
          labels.add(SizedBox(width: columnStride));
        }
      }
      return labels;
    }

    Widget buildFilterButton(String label, String mode) {
      final isActive = filterMode == mode;
      return GestureDetector(
        onTap: () {
          setState(() {
            filterMode = mode;
            final key = _formatDateKey(selectedDate);
            selectedCount = _getActiveCounts()[key] ?? 0;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentColor : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.white10,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black : Colors.white70,
            ),
          ),
        ),
      );
    }

    Widget buildStreakCard(String title, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 9.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yıllık İzleme Sıklığı',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '$selectedYear içinde $yearTotal İzleme',
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Year Navigation
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: selectedYear > _minYear ? Colors.white : Colors.white24,
                onPressed: selectedYear > _minYear ? () => _changeYear(-1) : null,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                iconSize: 20,
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$selectedYear',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: selectedYear < _maxYear ? Colors.white : Colors.white24,
                onPressed: selectedYear < _maxYear ? () => _changeYear(1) : null,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              buildFilterButton('Tümü', 'all'),
              const SizedBox(width: 6),
              buildFilterButton('Filmler', 'movies'),
              const SizedBox(width: 6),
              buildFilterButton('Diziler', 'tv'),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Tooltip / Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                      children: [
                        TextSpan(
                          text: '${_formatDateTurkish(selectedDate)} ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(
                          text: selectedCount == 0
                              ? 'tarihinde izleme kaydı yok.'
                              : 'tarihinde ',
                        ),
                        if (selectedCount > 0)
                          TextSpan(
                            text: '$selectedCount film/dizi ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                          ),
                        if (selectedCount > 0)
                          const TextSpan(text: 'izlediniz.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Heatmap Grid with Mon, Wed, Fri day labels — sized to
          // always fit the available width (no horizontal scrolling), so
          // the full year is visible on any phone screen at once.
          LayoutBuilder(
            builder: (context, constraints) {
              const dayLabelsWidth = 24.0;
              const gap = 2.0;
              final gridWidth = constraints.maxWidth - dayLabelsWidth - 6;
              final columnStride = gridWidth / 53;
              final cellSize = (columnStride - gap).clamp(3.0, 12.0);
              final rowStride = cellSize + gap;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day Labels
                  SizedBox(
                    width: dayLabelsWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18), // offset for month labels
                        _buildDayLabel('Pzt', rowStride),
                        SizedBox(height: rowStride),
                        _buildDayLabel('Çar', rowStride),
                        SizedBox(height: rowStride),
                        _buildDayLabel('Cum', rowStride),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Grid Area
                  SizedBox(
                    width: gridWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Labels Row
                        Row(children: buildMonthLabels(columnStride)),
                        const SizedBox(height: 6),

                        // Grid Columns
                        Row(
                          children: List.generate(53, (colIndex) {
                            return Container(
                              width: columnStride,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: List.generate(7, (rowIndex) {
                                  final dayOffset = colIndex * 7 + rowIndex;
                                  final cellDate = startMonday.add(Duration(days: dayOffset));
                                  final cellDateKey = _formatDateKey(cellDate);
                                  final count = activeCounts[cellDateKey] ?? 0;
                                  final isSelected = _formatDateKey(selectedDate) == cellDateKey;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDate = cellDate;
                                        selectedCount = count;
                                      });
                                    },
                                    child: Container(
                                      width: cellSize,
                                      height: cellSize,
                                      margin: EdgeInsets.only(bottom: gap, right: gap),
                                      decoration: BoxDecoration(
                                        color: _getCellColor(count),
                                        borderRadius: BorderRadius.circular(2),
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 1.0)
                                            : Border.all(color: Colors.transparent, width: 0.5),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Daha az',
                style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 6),
              _buildLegendCell(0),
              _buildLegendCell(1),
              _buildLegendCell(2),
              _buildLegendCell(3),
              _buildLegendCell(4),
              const SizedBox(width: 6),
              Text(
                'Daha çok',
                style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak Info Cards Box (v0.8.2)
          Row(
            children: [
              buildStreakCard('Mevcut Seri', '${widget.insights.currentStreak} Gün', Icons.local_fire_department_rounded, Colors.orange),
              const SizedBox(width: 12),
              buildStreakCard('En Uzun Seri', '${widget.insights.longestStreak} Gün', Icons.emoji_events_rounded, AppTheme.ratingColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 8.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLegendCell(int level) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: _getCellColor(level),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
