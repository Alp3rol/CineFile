import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/theme/app_theme.dart';

// "Maraton Mücadelesi" banner shown when the collection has a targetDate
// (v0.9.0). Only rendered by the caller when list.targetDate != null.
class CustomListMarathonBanner extends StatelessWidget {
  final DateTime targetDate;
  final double progress;
  final int remainingCount;

  const CustomListMarathonBanner({
    super.key,
    required this.targetDate,
    required this.progress,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.08),
            Colors.purple.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppTheme.accentColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).marathonTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatShortDate(context, targetDate),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  targetDate.isBefore(DateTime.now())
                      ? AppLocalizations.of(context).marathonExpired
                      : AppLocalizations.of(context).marathonDaysLeft(targetDate.difference(DateTime.now()).inDays + 1),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress == 1.0 ? AppLocalizations.of(context).marathonCompleted : AppLocalizations.of(context).marathonRemaining(remainingCount),
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: progress == 1.0 ? Colors.greenAccent : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
