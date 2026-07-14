// Shared date/color helpers for the contribution heatmap widgets
// (contribution_heatmap.dart, _grid.dart, _legend.dart, _badges.dart).
import 'package:flutter/material.dart';

String formatHeatmapDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatHeatmapDateTurkish(DateTime date) {
  const months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String heatmapMonthName(int month) {
  const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
  return months[month - 1];
}

// Neon renk paleti — bilinçli olarak AppTheme'in kırmızı/altın sinematik
// temasından ayrık tutuluyor, sadece bu ısı haritasına özel.
class HeatmapColors {
  static const Color neonCyan = Color(0xFF00F3FF); // sadece film
  static const Color neonPink = Color(0xFFFF007F); // sadece dizi
  static const Color neonPurple = Color(0xFF9B51E0); // film + dizi
  static const Color emptyCell = Color(0xFF15181F);

  // Boş hücreler tek bir sabit dekorasyona işaret eder: filtre/gölge/animasyon
  // yok, böylece 365 hücrenin büyük çoğunluğu render sırasında ekstra
  // hesaplama yapmaz.
  static const BoxDecoration emptyCellDecoration = BoxDecoration(
    color: emptyCell,
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );

  static BoxDecoration cellDecoration(int movies, int tv, {bool boosted = false}) {
    final total = movies + tv;
    if (total == 0) return emptyCellDecoration;

    final Color baseColor;
    if (movies > 0 && tv > 0) {
      baseColor = neonPurple;
    } else if (tv > 0) {
      baseColor = neonPink;
    } else {
      baseColor = neonCyan;
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
}
