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
  // Neon renk paleti — bilinçli olarak AppTheme'in kırmızı/altın sinematik
  // temasından ayrık tutuluyor, sadece bu ısı haritasına özel.
  static const Color _neonCyan = Color(0xFF00F3FF); // sadece film
  static const Color _neonPink = Color(0xFFFF007F); // sadece dizi
  static const Color _neonPurple = Color(0xFF9B51E0); // film + dizi
  static const Color _emptyCellColor = Color(0xFF15181F);

  // Hücre boyutu artık ekran genişliğine göre küçültülmüyor: grid kendi
  // yatay scroll'unda, sabit ve okunaklı bir boyutta kalıyor.
  static const double _cellSize = 14.0;
  static const double _gap = 3.0;
  static const double _rowStride = _cellSize + _gap;
  static const double _dayLabelsWidth = 26.0;

  late DateTime selectedDate;
  late int selectedMovies;
  late int selectedTv;
  late int selectedYear;
  String filterMode = 'all'; // 'all', 'movies', 'tv'

  final ScrollController _gridScrollController = ScrollController();
  int? _autoScrolledForYear;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    selectedDate = today;
    selectedMovies = widget.insights.dailyMovieWatchCounts[todayKey] ?? 0;
    selectedTv = widget.insights.dailyTvWatchCounts[todayKey] ?? 0;
    selectedYear = today.year;
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  int get _maxYear => DateTime.now().year;

  int get _minYear {
    final years = widget.insights.dailyWatchCounts.keys.map(
      (k) => int.parse(k.split('-').first),
    );
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
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return months[month - 1];
  }

  // Boş hücreler tek bir sabit dekorasyona işaret eder: filtre/gölge/animasyon
  // yok, böylece 365 hücrenin büyük çoğunluğu render sırasında ekstra
  // hesaplama yapmaz.
  static const BoxDecoration _emptyCellDecoration = BoxDecoration(
    color: _emptyCellColor,
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );

  BoxDecoration _getCellDecoration(int movies, int tv, {bool boosted = false}) {
    final total = movies + tv;
    if (total == 0) return _emptyCellDecoration;

    final Color baseColor;
    if (movies > 0 && tv > 0) {
      baseColor = _neonPurple;
    } else if (tv > 0) {
      baseColor = _neonPink;
    } else {
      baseColor = _neonCyan;
    }

    late final double alpha;
    late final double glowBlur;
    late final double glowSpread;
    if (total <= 2) {
      alpha = 0.3;
      glowBlur = 3;
      glowSpread = 0;
    } else if (total <= 5) {
      alpha = 0.6;
      glowBlur = 6;
      glowSpread = 0.5;
    } else {
      alpha = 1.0;
      glowBlur = 10;
      glowSpread = 1.5;
    }
    final boost = boosted ? 1.4 : 1.0;

    return BoxDecoration(
      color: baseColor.withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: baseColor.withValues(alpha: (alpha * 0.7).clamp(0.0, 1.0)),
          blurRadius: glowBlur * boost,
          spreadRadius: glowSpread * boost,
        ),
      ],
    );
  }

  int _activeMovies(String key) {
    if (filterMode == 'tv') return 0;
    return widget.insights.dailyMovieWatchCounts[key] ?? 0;
  }

  int _activeTv(String key) {
    if (filterMode == 'movies') return 0;
    return widget.insights.dailyTvWatchCounts[key] ?? 0;
  }

  // Yıl değişiminde grid'i bir kez ilgili konuma kaydırır: içinde
  // bulunduğumuz yılsa bugüne, geçmiş bir yılsa yıl sonuna. Hedef, viewport
  // genişliğini ScrollPosition'dan değil LayoutBuilder'ın verdiği kesin
  // constraint'ten hesaplar — ilk frame'de ScrollPosition'ın
  // viewportDimension/maxScrollExtent değerleri henüz güvenilir olmayabiliyor
  // (bu widget bir SingleChildScrollView içinde iç içe olduğu için), bu da
  // yanlış (genelde çok kısa) bir kaydırma hedefine yol açıyordu.
  void _scheduleAutoScroll(DateTime startMonday, double viewportWidth) {
    if (_autoScrolledForYear == selectedYear) return;
    _autoScrolledForYear = selectedYear;

    const contentWidth = 53 * _rowStride;
    final maxExtent = (contentWidth - viewportWidth).clamp(
      0.0,
      double.infinity,
    );

    double target;
    if (selectedYear == _maxYear) {
      final dayOffset = DateTime.now().difference(startMonday).inDays;
      final colIndex = dayOffset ~/ 7;
      target = (colIndex * _rowStride) - viewportWidth / 2 + _rowStride / 2;
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
    final startDate = DateTime(selectedYear, 1, 1);
    final startMonday = startDate.subtract(
      Duration(days: startDate.weekday - 1),
    );

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
      final sorted = widget.insights.timeOfDayTrend.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.first.value > 0) peakTimeOfDay = sorted.first.key;
    }

    // Builds the month-label row for the fixed per-column stride, so labels
    // stay aligned with the (horizontally scrollable) grid below them.
    List<Widget> buildMonthLabels() {
      final labels = <Widget>[];
      String? lastMonthName;
      for (int w = 0; w < 53; w++) {
        final colDate = startMonday.add(Duration(days: w * 7));
        final monthName = _getMonthName(colDate.month);
        if (lastMonthName != monthName) {
          labels.add(
            SizedBox(
              width: _rowStride * 4, // roughly a month's worth of columns
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
          labels.add(const SizedBox(width: _rowStride));
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
            selectedMovies = _activeMovies(key);
            selectedTv = _activeTv(key);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? _neonPurple
                : Colors.white.withValues(alpha: 0.04),
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

    Widget buildBadge(IconData icon, String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$selectedYear içinde $yearTotal İzleme',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: _neonPurple,
                  fontWeight: FontWeight.bold,
                ),
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
                    color: selectedYear > _minYear
                        ? Colors.white
                        : Colors.white24,
                    onPressed: selectedYear > _minYear
                        ? () => _changeYear(-1)
                        : null,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    iconSize: 20,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$selectedYear',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: selectedYear < _maxYear
                        ? Colors.white
                        : Colors.white24,
                    onPressed: selectedYear < _maxYear
                        ? () => _changeYear(1)
                        : null,
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
                    buildFilterButton('Tümü', 'all'),
                    buildFilterButton('Filmler', 'movies'),
                    buildFilterButton('Diziler', 'tv'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rozetler (heatmap'e özgü metrikler) — hep tek satırda, eşit paylaşımlı.
          Row(
            children: [
              buildBadge(
                Icons.event_available_rounded,
                'Aktif Gün',
                '$activeDays',
                _neonCyan,
              ),
              const SizedBox(width: 8),
              buildBadge(
                Icons.local_fire_department_rounded,
                'Mevcut Seri',
                '${widget.insights.currentStreak}g',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              buildBadge(
                Icons.schedule_rounded,
                'Yoğun Saat',
                peakTimeOfDay,
                _neonPink,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Seçili gün bilgisi — artık kutusuz, ince bir alt-metin.
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: _neonPurple),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: Colors.white70,
                    ),
                    children: [
                      TextSpan(
                        text: '${_formatDateTurkish(selectedDate)} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: (selectedMovies + selectedTv) == 0
                            ? 'tarihinde izleme kaydı yok.'
                            : '• ',
                      ),
                      if (selectedMovies > 0)
                        TextSpan(
                          text: '$selectedMovies Film',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _neonCyan,
                          ),
                        ),
                      if (selectedMovies > 0 && selectedTv > 0)
                        const TextSpan(text: ', '),
                      if (selectedTv > 0)
                        TextSpan(
                          text: '$selectedTv Dizi Bölümü',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _neonPink,
                          ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final gridViewportWidth =
                  constraints.maxWidth - _dayLabelsWidth - 6;
              _scheduleAutoScroll(startMonday, gridViewportWidth);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _dayLabelsWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18), // offset for month labels
                        _buildDayLabel('Pzt', _rowStride),
                        const SizedBox(height: _rowStride),
                        _buildDayLabel('Çar', _rowStride),
                        const SizedBox(height: _rowStride),
                        _buildDayLabel('Cum', _rowStride),
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
                        width: 53 * _rowStride,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month Labels Row
                            Row(children: buildMonthLabels()),
                            const SizedBox(height: 6),

                            // Grid Columns
                            Row(
                              children: List.generate(53, (colIndex) {
                                return SizedBox(
                                  width: _rowStride,
                                  child: Column(
                                    children: List.generate(7, (rowIndex) {
                                      final dayOffset = colIndex * 7 + rowIndex;
                                      final cellDate = startMonday.add(
                                        Duration(days: dayOffset),
                                      );
                                      final cellDateKey = _formatDateKey(
                                        cellDate,
                                      );
                                      final movies = _activeMovies(cellDateKey);
                                      final tv = _activeTv(cellDateKey);
                                      final isSelected =
                                          _formatDateKey(selectedDate) ==
                                          cellDateKey;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDate = cellDate;
                                            selectedMovies = movies;
                                            selectedTv = tv;
                                          });
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            width: _cellSize,
                                            height: _cellSize,
                                            margin: const EdgeInsets.only(
                                              bottom: _gap,
                                              right: _gap,
                                            ),
                                            decoration:
                                                _getCellDecoration(
                                                  movies,
                                                  tv,
                                                  boosted: isSelected,
                                                ).copyWith(
                                                  border: isSelected
                                                      ? Border.all(
                                                          color: Colors.white,
                                                          width: 1.0,
                                                        )
                                                      : Border.all(
                                                          color: Colors
                                                              .transparent,
                                                          width: 0.5,
                                                        ),
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
          ),
          const SizedBox(height: 14),

          // Legend Row — üç renk: yalnız film, yalnız dizi, ikisi birden.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Az',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              _buildLegendCell(_neonCyan, 0.3),
              _buildLegendCell(_neonCyan, 1.0),
              const SizedBox(width: 10),
              _buildLegendCell(_neonPink, 0.3),
              _buildLegendCell(_neonPink, 1.0),
              const SizedBox(width: 10),
              _buildLegendCell(_neonPurple, 0.3),
              _buildLegendCell(_neonPurple, 1.0),
              const SizedBox(width: 8),
              Text(
                'Çok',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendLabel('Film', _neonCyan),
              const SizedBox(width: 14),
              _buildLegendLabel('Dizi', _neonPink),
              const SizedBox(width: 14),
              _buildLegendLabel('İkisi', _neonPurple),
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
          style: GoogleFonts.inter(
            fontSize: 8.5,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendCell(Color color, double alpha) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildLegendLabel(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
