import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Categories for achievement badges.
///
/// The display name is not stored on the enum: it used to be a Turkish string
/// baked into the constant, which a const enum can never localize. Callers use
/// [AchievementCategoryLabel.label].
enum AchievementCategory {
  milestone(Icons.workspace_premium_rounded),
  timeOfDay(Icons.nightlight_round),
  directors(Icons.movie_creation_rounded),
  genres(Icons.category_rounded),
  critic(Icons.rate_review_rounded),
  tvShows(Icons.tv_rounded);

  final IconData icon;

  const AchievementCategory(this.icon);
}

extension AchievementCategoryLabel on AchievementCategory {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AchievementCategory.milestone => l10n.badgeCategoryMilestone,
      AchievementCategory.timeOfDay => l10n.badgeCategoryTime,
      AchievementCategory.directors => l10n.badgeCategoryDirectors,
      AchievementCategory.genres => l10n.badgeCategoryGenres,
      AchievementCategory.critic => l10n.badgeCategoryCritic,
      AchievementCategory.tvShows => l10n.badgeCategorySeries,
    };
  }
}

/// Badge Tier rank enum
enum BadgeTier {
  locked(0, Colors.grey, ''),
  bronze(1, Color(0xFFCD7F32), '🥉'),
  silver(2, Color(0xFFC0C0C0), '🥈'),
  gold(3, Color(0xFFFFD700), '🥇'),
  platinum(4, Color(0xFFE5E4E2), '💎');

  final int level;
  final Color color;
  final String symbol;

  const BadgeTier(this.level, this.color, this.symbol);
}

extension BadgeTierLabel on BadgeTier {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BadgeTier.locked => l10n.tierLocked,
      BadgeTier.bronze => l10n.tierBronze,
      BadgeTier.silver => l10n.tierSilver,
      BadgeTier.gold => l10n.tierGold,
      BadgeTier.platinum => l10n.tierPlatinum,
    };
  }
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
