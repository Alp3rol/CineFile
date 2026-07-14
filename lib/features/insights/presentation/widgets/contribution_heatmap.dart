import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';
import 'contribution_heatmap_badges.dart';
import 'contribution_heatmap_grid.dart';
import 'contribution_heatmap_legend.dart';
import 'contribution_heatmap_utils.dart';

class ContributionHeatmap extends StatefulWidget {
  final InsightsData insights;

  const ContributionHeatmap({super.key, required this.insights});

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  late DateTime selectedDate;
  late int selectedMovies;
  late int selectedTv;
  late int selectedYear;
  String filterMode = 'all'; // 'all', 'movies', 'tv'

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayKey = formatHeatmapDateKey(today);
    selectedDate = today;
    selectedMovies = widget.insights.dailyMovieWatchCounts[todayKey] ?? 0;
    selectedTv = widget.insights.dailyTvWatchCounts[todayKey] ?? 0;
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

  int _activeMovies(String key) {
    if (filterMode == 'tv') return 0;
    return widget.insights.dailyMovieWatchCounts[key] ?? 0;
  }

  int _activeTv(String key) {
    if (filterMode == 'movies') return 0;
    return widget.insights.dailyTvWatchCounts[key] ?? 0;
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      selectedDate = day;
      selectedMovies = _activeMovies(formatHeatmapDateKey(day));
      selectedTv = _activeTv(formatHeatmapDateKey(day));
    });
  }

  Widget _buildFilterButton(String label, String mode) {
    final isActive = filterMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          filterMode = mode;
          final key = formatHeatmapDateKey(selectedDate);
          selectedMovies = _activeMovies(key);
          selectedTv = _activeTv(key);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? HeatmapColors.neonPurple : Colors.white.withValues(alpha: 0.04),
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
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Seçili yıla ait toplam izleme ve aktif gün sayısı.
    int yearTotal = 0;
    int activeDays = 0;
    for (final entry in widget.insights.dailyWatchCounts.entries) {
      if (int.parse(entry.key.split('-').first) == selectedYear) {
        yearTotal += entry.value;
        if (entry.value > 0) activeDays++;
      }
    }

    // Genel (tüm zamanlar) en yoğun zaman dilimi — provider yıl bazlı bu
    // kırılımı tutmuyor, bu yüzden rozet metninde "Genel" ima edilir.
    String peakTimeOfDay = '—';
    if (widget.insights.timeOfDayTrend.isNotEmpty) {
      final sorted = widget.insights.timeOfDayTrend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.first.value > 0) peakTimeOfDay = sorted.first.key;
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
                style: GoogleFonts.outfit(fontSize: 11, color: HeatmapColors.neonPurple, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Yıl gezinme + filtreler tek satırda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                    width: 40,
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
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildFilterButton('Tümü', 'all'),
                    _buildFilterButton('Filmler', 'movies'),
                    _buildFilterButton('Diziler', 'tv'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ContributionHeatmapBadges(
            activeDays: activeDays,
            currentStreak: widget.insights.currentStreak,
            peakTimeOfDay: peakTimeOfDay,
          ),
          const SizedBox(height: 10),

          // Seçili gün bilgisi — artık kutusuz, ince bir alt-metin.
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: HeatmapColors.neonPurple),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: '${formatHeatmapDateTurkish(selectedDate)} ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(
                        text: (selectedMovies + selectedTv) == 0 ? 'tarihinde izleme kaydı yok.' : '• ',
                      ),
                      if (selectedMovies > 0)
                        TextSpan(
                          text: '$selectedMovies Film',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: HeatmapColors.neonCyan),
                        ),
                      if (selectedMovies > 0 && selectedTv > 0) const TextSpan(text: ', '),
                      if (selectedTv > 0)
                        TextSpan(
                          text: '$selectedTv Dizi Bölümü',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: HeatmapColors.neonPink),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Heatmap Grid — sabit, okunaklı hücre boyutu; gün etiketleri
          // solda sabit kalır, grid+ay etiketleri kendi içinde yatay kayar.
          ContributionHeatmapGrid(
            selectedYear: selectedYear,
            selectedDate: selectedDate,
            activeMovies: _activeMovies,
            activeTv: _activeTv,
            onDaySelected: _onDaySelected,
          ),
          const SizedBox(height: 14),

          const ContributionHeatmapLegend(),
        ],
      ),
    );
  }
}
