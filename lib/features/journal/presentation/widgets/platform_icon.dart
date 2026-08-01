import 'package:flutter/material.dart';
import '../../../../core/ui/ui.dart';

/// Tiny marker identifying where a title was watched.
///
/// Two kinds of thing live here and they are coloured from different places:
/// streaming services are other people's brands and take their real colours
/// from [BrandColors]; "cinema" and "home" are places rather than brands, so
/// they take ours.
const double _iconSize = 10;

/// Lettermark badge for a service whose logo is a single character.
Widget _serviceBadge(BuildContext context, String letter, Color brand) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
    decoration: BoxDecoration(
      color: brand.withValues(alpha: AppOpacity.soft),
      borderRadius: AppRadius.allXs,
      border: Border.all(color: brand, width: 0.5),
    ),
    child: Text(
      letter,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: brand,
          ),
    ),
  );
}

// v0.6.3: Platform Icon Resolver
Widget buildPlatformIcon(BuildContext context, String? place) {
  const fallback = Icon(
    Icons.location_on_outlined,
    size: _iconSize,
    color: AppColors.textSecondary,
  );

  if (place == null) return fallback;
  final lowerPlace = place.toLowerCase();

  if (lowerPlace.contains('netflix')) {
    return _serviceBadge(context, 'N', BrandColors.netflixRed);
  }

  if (lowerPlace.contains('sinema') || lowerPlace.contains('cinema')) {
    // A place, not a brand — the gold that marks ratings and tickets.
    return const Icon(
      Icons.local_activity_rounded,
      size: _iconSize,
      color: AppColors.rating,
    );
  }

  if (lowerPlace.contains('ev') || lowerPlace.contains('home')) {
    return const Icon(
      Icons.home_rounded,
      size: _iconSize,
      color: AppColors.success,
    );
  }

  if (lowerPlace.contains('prime') || lowerPlace.contains('amazon')) {
    return _serviceBadge(context, 'a', BrandColors.primeBlue);
  }

  if (lowerPlace.contains('disney')) {
    return const Icon(
      Icons.star_rounded,
      size: _iconSize,
      color: BrandColors.disneyBlue,
    );
  }

  return fallback;
}
