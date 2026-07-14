import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'contribution_heatmap_utils.dart';

// The scrollable 53-week x 7-day grid itself, plus its day/month labels.
// Owns the horizontal ScrollController and the "auto-scroll to today/year-end
// once per selected year" behavior — the rest of the heatmap (header, year
// nav, badges, legend) is stateless and lives in contribution_heatmap.dart.
class ContributionHeatmapGrid extends StatefulWidget {
  final int selectedYear;
  final DateTime selectedDate;
  final int Function(String dateKey) activeMovies;
  final int Function(String dateKey) activeTv;
  final ValueChanged<DateTime> onDaySelected;

  static const double cellSize = 14.0;
  static const double gap = 3.0;
  static const double rowStride = cellSize + gap;
  static const double dayLabelsWidth = 26.0;

  const ContributionHeatmapGrid({
    super.key,
    required this.selectedYear,
    required this.selectedDate,
    required this.activeMovies,
    required this.activeTv,
    required this.onDaySelected,
  });

  @override
  State<ContributionHeatmapGrid> createState() => _ContributionHeatmapGridState();
}

class _ContributionHeatmapGridState extends State<ContributionHeatmapGrid> {
  final ScrollController _gridScrollController = ScrollController();
  int? _autoScrolledForYear;

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  // Builds the month-label row for the fixed per-column stride, so labels
  // stay aligned with the (horizontally scrollable) grid below them.
  List<Widget> _buildMonthLabels(DateTime startMonday) {
    final labels = <Widget>[];
    String? lastMonthName;
    for (int w = 0; w < 53; w++) {
      final colDate = startMonday.add(Duration(days: w * 7));
      final monthName = heatmapMonthName(colDate.month);
      if (lastMonthName != monthName) {
        labels.add(
          SizedBox(
            width: ContributionHeatmapGrid.rowStride * 4, // roughly a month's worth of columns
            child: Text(
              monthName,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        lastMonthName = monthName;
        w += 3; // skip
      } else {
        labels.add(const SizedBox(width: ContributionHeatmapGrid.rowStride));
      }
    }
    return labels;
  }

  Widget _dayLabel(String label, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8.5,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Yıl değişiminde grid'i bir kez ilgili konuma kaydırır: içinde
  // bulunduğumuz yılsa bugüne, geçmiş bir yılsa yıl sonuna. Hedef, viewport
  // genişliğini ScrollPosition'dan değil LayoutBuilder'ın verdiği kesin
  // constraint'ten hesaplar — ilk frame'de ScrollPosition'ın
  // viewportDimension/maxScrollExtent değerleri henüz güvenilir olmayabiliyor
  // (bu widget bir SingleChildScrollView içinde iç içe olduğu için), bu da
  // yanlış (genelde çok kısa) bir kaydırma hedefine yol açıyordu.
  void _scheduleAutoScroll(DateTime startMonday, double viewportWidth) {
    if (_autoScrolledForYear == widget.selectedYear) return;
    _autoScrolledForYear = widget.selectedYear;

    final contentWidth = 53 * ContributionHeatmapGrid.rowStride;
    final maxExtent = (contentWidth - viewportWidth).clamp(0.0, double.infinity);

    double target;
    if (widget.selectedYear == DateTime.now().year) {
      final dayOffset = DateTime.now().difference(startMonday).inDays;
      final colIndex = dayOffset ~/ 7;
      target = (colIndex * ContributionHeatmapGrid.rowStride) - viewportWidth / 2 + ContributionHeatmapGrid.rowStride / 2;
    } else {
      target = maxExtent;
    }
    target = target.clamp(0.0, maxExtent);

    void attemptJump() {
      if (!mounted) return;
      if (!_gridScrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attemptJump());
        return;
      }
      _gridScrollController.jumpTo(target);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => attemptJump());
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(widget.selectedYear, 1, 1);
    final startMonday = startDate.subtract(Duration(days: startDate.weekday - 1));
    final selectedDateKey = formatHeatmapDateKey(widget.selectedDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridViewportWidth = constraints.maxWidth - ContributionHeatmapGrid.dayLabelsWidth - 6;
        _scheduleAutoScroll(startMonday, gridViewportWidth);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ContributionHeatmapGrid.dayLabelsWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18), // offset for month labels
                  _dayLabel('Pzt', ContributionHeatmapGrid.rowStride),
                  const SizedBox(height: ContributionHeatmapGrid.rowStride),
                  _dayLabel('Çar', ContributionHeatmapGrid.rowStride),
                  const SizedBox(height: ContributionHeatmapGrid.rowStride),
                  _dayLabel('Cum', ContributionHeatmapGrid.rowStride),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SingleChildScrollView(
                controller: _gridScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: 53 * ContributionHeatmapGrid.rowStride,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Labels Row
                      Row(children: _buildMonthLabels(startMonday)),
                      const SizedBox(height: 6),

                      // Grid Columns
                      Row(
                        children: List.generate(53, (colIndex) {
                          return SizedBox(
                            width: ContributionHeatmapGrid.rowStride,
                            child: Column(
                              children: List.generate(7, (rowIndex) {
                                final dayOffset = colIndex * 7 + rowIndex;
                                final cellDate = startMonday.add(Duration(days: dayOffset));
                                final cellDateKey = formatHeatmapDateKey(cellDate);
                                final movies = widget.activeMovies(cellDateKey);
                                final tv = widget.activeTv(cellDateKey);
                                final isSelected = selectedDateKey == cellDateKey;

                                return GestureDetector(
                                  onTap: () => widget.onDaySelected(cellDate),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      width: ContributionHeatmapGrid.cellSize,
                                      height: ContributionHeatmapGrid.cellSize,
                                      margin: const EdgeInsets.only(
                                        bottom: ContributionHeatmapGrid.gap,
                                        right: ContributionHeatmapGrid.gap,
                                      ),
                                      decoration: HeatmapColors.cellDecoration(movies, tv, boosted: isSelected).copyWith(
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 1.0)
                                            : Border.all(color: Colors.transparent, width: 0.5),
                                      ),
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
              ),
            ),
          ],
        );
      },
    );
  }
}
