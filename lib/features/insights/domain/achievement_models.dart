import 'package:flutter/material.dart';

/// Categories for achievement badges.
enum AchievementCategory {
  milestone('Hacim & Maraton', Icons.workspace_premium_rounded),
  timeOfDay('Zaman & Atmosfer', Icons.nightlight_round),
  directors('Yönetmenler & Auteurs', Icons.movie_creation_rounded),
  genres('Türler & Temalar', Icons.category_rounded),
  critic('Eleştirmen & Günlük', Icons.rate_review_rounded),
  tvShows('Dizi & Sezon', Icons.tv_rounded);

  final String label;
  final IconData icon;

  const AchievementCategory(this.label, this.icon);
}

/// Badge Tier rank enum
enum BadgeTier {
  locked(0, 'Kilitli', Colors.grey, ''),
  bronze(1, 'Bronz', Color(0xFFCD7F32), '🥉'),
  silver(2, 'Gümüş', Color(0xFFC0C0C0), '🥈'),
  gold(3, 'Altın', Color(0xFFFFD700), '🥇'),
  platinum(4, 'Platin', Color(0xFFE5E4E2), '💎');

  final int level;
  final String label;
  final Color color;
  final String symbol;

  const BadgeTier(this.level, this.label, this.color, this.symbol);
}

/// Represents a single tiered achievement badge state.
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0 towards next tier
  final int currentValue;
  final int targetValue;
  final DateTime? unlockedAt;

  // Tiered System Fields
  final int currentTier; // 0 (locked) to maxTier
  final int maxTier; // Maximum tier for this series (e.g. 3 or 4)
  final String currentTierTitle; // Name of the unlocked tier (e.g. "Kovboy & Şerif")
  final String? nextTierTitle; // Name of next tier to unlock
  final int nextTargetValue; // Target value for next tier

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.isUnlocked,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    required this.currentTier,
    required this.maxTier,
    required this.currentTierTitle,
    this.nextTierTitle,
    required this.nextTargetValue,
    this.unlockedAt,
  });

  BadgeTier get tier {
    if (!isUnlocked || currentTier <= 0) return BadgeTier.locked;
    if (currentTier == 1) return BadgeTier.bronze;
    if (currentTier == 2) return BadgeTier.silver;
    if (currentTier == 3) return BadgeTier.gold;
    return BadgeTier.platinum;
  }

  String get stars {
    if (!isUnlocked || currentTier <= 0) return '';
    return '⭐' * currentTier;
  }
}
