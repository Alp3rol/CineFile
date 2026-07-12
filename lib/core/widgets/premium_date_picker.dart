import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class PremiumDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const PremiumDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  /// showDatePicker yerine çağrılacak statik yardımcı fonksiyon
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => PremiumDatePicker(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<PremiumDatePicker> createState() => _PremiumDatePickerState();
}

class _PremiumDatePickerState extends State<PremiumDatePicker> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Tapping the "Ay Yıl" header swaps the day grid for a year grid so
  // jumping to an old year doesn't require clicking the month arrow dozens
  // of times (the reported problem for shows/movies watched years ago).
  bool _showYearPicker = false;
  final ScrollController _yearScrollController = ScrollController();

  final List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _toggleYearPicker() {
    setState(() => _showYearPicker = !_showYearPicker);
    if (_showYearPicker) {
      // Scroll the grid so the currently focused year is roughly centered
      // instead of the user landing on row 1 and having to scroll manually.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_yearScrollController.hasClients) return;
        const rowHeight = 52.0;
        final selectedIndex = _focusedMonth.year - widget.firstDate.year;
        final selectedRow = selectedIndex ~/ 3;
        final target = (selectedRow * rowHeight - rowHeight * 2).clamp(
          0.0,
          _yearScrollController.position.maxScrollExtent,
        );
        _yearScrollController.jumpTo(target);
      });
    }
  }

  void _selectYear(int year) {
    setState(() {
      // Only moves the calendar view to that year/month — the user still
      // taps a day afterwards, same as picking a month via the arrows.
      var newFocused = DateTime(year, _focusedMonth.month, 1);
      final minMonth = DateTime(widget.firstDate.year, widget.firstDate.month, 1);
      final maxMonth = DateTime(widget.lastDate.year, widget.lastDate.month, 1);
      if (newFocused.isBefore(minMonth)) newFocused = minMonth;
      if (newFocused.isAfter(maxMonth)) newFocused = maxMonth;
      _focusedMonth = newFocused;
      _showYearPicker = false;
    });
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  void _prevMonth() {
    final prev = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final minLimit = DateTime(widget.firstDate.year, widget.firstDate.month, 1);
    if (prev.isAfter(minLimit) || prev.isAtSameMomentAs(minLimit)) {
      setState(() {
        _focusedMonth = prev;
      });
    }
  }

  void _nextMonth() {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    final maxLimit = DateTime(widget.lastDate.year, widget.lastDate.month, 1);
    if (next.isBefore(maxLimit) || next.isAtSameMomentAs(maxLimit)) {
      setState(() {
        _focusedMonth = next;
      });
    }
  }

  bool _isDateDisabled(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final first = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    return d.isBefore(first) || d.isAfter(last);
  }

  @override
  Widget build(BuildContext context) {
    final daysCount = _daysInMonth(_focusedMonth);
    
    // Flutter'ın DateTime.weekday değeri: Pzt=1, Sal=2, Çar=3, Per=4, Cum=5, Cmt=6, Paz=7
    final firstDayWeekday = _focusedMonth.weekday; 
    
    // Pazartesi'den başlamak için pad (boşluk) sayısını hesapla
    // Eğer ilk gün Pzt (1) ise 0 boşluk, Paz (7) ise 6 boşluk
    final padCount = firstDayWeekday - 1;

    final today = DateTime.now();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        opacity: 0.9,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Başlık ve İkon
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tarih Seçin',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ay ve Yıl Seçimi — başlığa dokununca yıl seçim ızgarasına geçer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: _showYearPicker ? null : _prevMonth,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleYearPicker,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _showYearPicker ? '${_focusedMonth.year}' : '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _showYearPicker ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: _showYearPicker ? null : _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_showYearPicker) ...[
              SizedBox(
                height: 260,
                child: GridView.builder(
                  controller: _yearScrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: widget.lastDate.year - widget.firstDate.year + 1,
                  itemBuilder: (context, index) {
                    final year = widget.firstDate.year + index;
                    final isSelectedYear = year == _focusedMonth.year;
                    return GestureDetector(
                      onTap: () => _selectYear(year),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelectedYear ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.05),
                        ),
                        child: Text(
                          '$year',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelectedYear ? FontWeight.bold : FontWeight.w500,
                            color: isSelectedYear ? Colors.white : Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Haftanın Günleri Başlıkları (Pzt'den Pazar'a)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'].map((day) {
                  return SizedBox(
                    width: 34,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Günler GridView Matrisi
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: padCount + daysCount,
                itemBuilder: (context, index) {
                  if (index < padCount) {
                    return const SizedBox();
                  }

                  final day = index - padCount + 1;
                  final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  final isDisabled = _isDateDisabled(cellDate);
                  final isSelected = _selectedDate.year == cellDate.year &&
                      _selectedDate.month == cellDate.month &&
                      _selectedDate.day == cellDate.day;
                  final isToday = today.year == cellDate.year &&
                      today.month == cellDate.month &&
                      today.day == cellDate.day;

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(() {
                              _selectedDate = cellDate;
                            });
                          },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.accentColor : Colors.transparent,
                        border: isToday && !isSelected
                            ? Border.all(color: AppTheme.ratingColor.withValues(alpha: 0.6), width: 1.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        '$day',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isDisabled
                              ? Colors.white24
                              : isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppTheme.ratingColor
                                      : Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE8362E),
                          Color(0xFFFA584F),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedDate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Onayla',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
