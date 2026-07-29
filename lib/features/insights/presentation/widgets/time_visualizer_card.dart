import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class TimeVisualizerCard extends StatefulWidget {
  final InsightsData data;
  const TimeVisualizerCard({super.key, required this.data});

  @override
  State<TimeVisualizerCard> createState() => _TimeVisualizerCardState();
}

class _TimeVisualizerCardState extends State<TimeVisualizerCard> {
  late final int _randomIndex;

  @override
  void initState() {
    super.initState();
    _randomIndex = Random().nextInt(16); // 16 different fun options
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalMins = widget.data.totalDurationMinutes;

    String formatNum(double val, int decimals) => val.toStringAsFixed(decimals);

    // Each entry pairs an emoji with one localized sentence. The divisor stays
    // here in code — only the wording is translated, and each language is free
    // to pick reference points that mean something to its readers (the Turkish
    // set leans on Istanbul–London flights and lahmacun, which travel badly).
    final comparisons = [
      (emoji: '💍', text: l10n.timeCompareLotr(formatNum(totalMins / 682, 1))),
      (emoji: '✈️', text: l10n.timeCompareFlight(formatNum(totalMins / 210, 1))),
      (emoji: '🧪', text: l10n.timeCompareBreakingBad(formatNum(totalMins / 3100, 1))),
      (emoji: '🥾', text: l10n.timeCompareWalk(formatNum(totalMins / 5400, 1))),
      (emoji: '📚', text: l10n.timeCompareBooks(formatNum(totalMins / 480, 0))),
      (emoji: '🌯', text: l10n.timeCompareFood(formatNum(totalMins / 3, 0))),
      (emoji: '🛰️', text: l10n.timeCompareIss(formatNum(totalMins / 90, 0))),
      (emoji: '⚡', text: l10n.timeCompareLight(formatNum(totalMins * 18.0, 0))),
      (emoji: '🧱', text: l10n.timeCompareMinecraft(formatNum(totalMins * 120.0, 0))),
      (emoji: '☕', text: l10n.timeCompareCoffee(formatNum(totalMins / 15, 0))),
      (emoji: '🎵', text: l10n.timeCompareMusic(formatNum(totalMins / 3.5, 0))),
      (emoji: '🎲', text: l10n.timeCompareMonopoly(formatNum(totalMins / 180, 1))),
      (emoji: '😴', text: l10n.timeCompareSleep(formatNum(totalMins / 480, 1))),
      (emoji: '💇', text: l10n.timeCompareHair(formatNum(totalMins * 0.000287, 3))),
      (emoji: '🧬', text: l10n.timeCompareCells(formatNum(totalMins * 200.0, 0))),
      (emoji: '🌍', text: l10n.timeCompareOrbit(formatNum(totalMins * 1.785, 0))),
    ];

    final selected = comparisons[_randomIndex % comparisons.length];

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.timeVisualizerTitle,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  selected.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.text,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.timeVisualizerFooter,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
