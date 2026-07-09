import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  final List<String> _weekdays = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
  
  final List<String> _monthsTr = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  // Get number of days in _focusedMonth
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Get the weekday of the 1st day of _focusedMonth (Pt: 1, Pz: 7)
  int _getFirstDayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday - 1; // pt: 0, pz: 6
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchRecordsAsync = ref.watch(allWatchRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
              child: Text(
                'Takvim',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),

            // Month Selector Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthsTr[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                        onPressed: _previousMonth,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calendar Layout Card
            Expanded(
              child: watchRecordsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
                data: (records) {
                  // Map watch records by date yyyy-MM-dd
                  final recordsByDate = <String, List<WatchRecordWithMovie>>{};
                  for (final item in records) {
                    final dateKey = '${item.record.watchDate.year}-${item.record.watchDate.month.toString().padLeft(2, '0')}-${item.record.watchDate.day.toString().padLeft(2, '0')}';
                    recordsByDate.putIfAbsent(dateKey, () => []).add(item);
                  }

                  return _buildCalendarGrid(recordsByDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, List<WatchRecordWithMovie>> recordsByDate) {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayOffset = _getFirstDayOffset(_focusedMonth);
    final totalCells = daysInMonth + firstDayOffset;
    final rowCount = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Weekdays Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return SizedBox(
                width: 40,
                child: Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Calendar GridView
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rowCount * 7,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final cellNumber = index - firstDayOffset + 1;
                final isCurrentMonthDay = cellNumber > 0 && cellNumber <= daysInMonth;

                if (!isCurrentMonthDay) {
                  return const SizedBox(); // Empty grid cell
                }

                // Date key for comparison
                final dateKey = '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}-${cellNumber.toString().padLeft(2, '0')}';
                final dayRecords = recordsByDate[dateKey] ?? [];

                return _buildDayCell(cellNumber, dayRecords);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Draw day cell
  Widget _buildDayCell(int day, List<WatchRecordWithMovie> dayRecords) {
    final hasRecords = dayRecords.isNotEmpty;
    
    // Check if it is today
    final now = DateTime.now();
    final isToday = now.year == _focusedMonth.year && now.month == _focusedMonth.month && now.day == day;

    return GestureDetector(
      onTap: hasRecords ? () => _showDayRecordsSheet(day, dayRecords) : null,
      child: GlassContainer(
        borderRadius: 10,
        opacity: isToday ? 0.8 : (hasRecords ? 0.7 : 0.4),
        border: Border.all(
          color: isToday
              ? AppTheme.accentColor
              : (hasRecords ? AppTheme.accentColor.withOpacity(0.3) : AppTheme.borderColor),
          width: isToday ? 1.5 : 1,
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Day number label
            Positioned(
              top: 2,
              left: 4,
              child: Text(
                '$day',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isToday ? AppTheme.accentColor : Colors.white70,
                ),
              ),
            ),
            
            // Poster thumbnail or dot indicator
            if (hasRecords)
              Positioned(
                bottom: 2,
                right: 2,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: dayRecords.first.movie.posterPath != null
                      ? NetworkImage('${ApiConstants.imagePathW500}${dayRecords.first.movie.posterPath}')
                      : null,
                  child: dayRecords.first.movie.posterPath == null
                      ? const Icon(Icons.movie_rounded, color: AppTheme.accentColor, size: 10)
                      : null,
                ),
              ),
              
            // Multiple watch indicator dot
            if (dayRecords.length > 1)
              Positioned(
                top: 2,
                right: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show records watched on clicked day
  void _showDayRecordsSheet(int day, List<WatchRecordWithMovie> dayRecords) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day ${_monthsTr[_focusedMonth.month - 1]} İzleme Kayıtlarınız',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dayRecords.length,
                  itemBuilder: (context, index) {
                    final item = dayRecords[index];
                    final movie = item.movie;
                    final record = item.record;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            ref.context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(tmdbId: movie.tmdbId, isTv: movie.isTv),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 12,
                          opacity: 0.5,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: movie.posterPath != null
                                      ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                                      : '',
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Puan: ${record.rating} • Mod: ${record.mood ?? "🍿"}',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                    if (record.watchPlace != null)
                                      Text(
                                        'Mekan: ${record.watchPlace}',
                                        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
