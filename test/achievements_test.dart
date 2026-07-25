import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/insights/domain/achievement_models.dart';

void main() {
  group('Tiered Achievement Models & Enum Tests', () {
    test('AchievementCategory contains 6 distinct categories with icons', () {
      expect(AchievementCategory.values.length, equals(6));
      expect(AchievementCategory.milestone.label, contains('Hacim'));
      expect(AchievementCategory.directors.label, contains('Yönetmenler'));
    });

    test('BadgeTier enum definitions', () {
      expect(BadgeTier.bronze.level, equals(1));
      expect(BadgeTier.silver.level, equals(2));
      expect(BadgeTier.gold.level, equals(3));
      expect(BadgeTier.platinum.level, equals(4));
    });

    test('AchievementBadge tier calculation and progress', () {
      const badge = AchievementBadge(
        id: 'western_series',
        title: 'Vahşi Batı Serisi',
        description: '5 Western filmi izle.',
        icon: '🤠',
        category: AchievementCategory.genres,
        isUnlocked: true,
        progress: 0.5,
        currentValue: 5,
        targetValue: 5,
        currentTier: 2,
        maxTier: 3,
        currentTierTitle: 'Kovboy & Şerif',
        nextTierTitle: 'İyi, Kötü ve Çirkin Efsanesi',
        nextTargetValue: 10,
      );

      expect(badge.isUnlocked, isTrue);
      expect(badge.tier, equals(BadgeTier.silver));
      expect(badge.currentTierTitle, equals('Kovboy & Şerif'));
      expect(badge.nextTierTitle, equals('İyi, Kötü ve Çirkin Efsanesi'));
      expect(badge.nextTargetValue, equals(10));
    });
  });
}
