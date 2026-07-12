import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// v0.6.3: Platform Icon Resolver
Widget buildPlatformIcon(String? place) {
  if (place == null) return const Icon(Icons.location_on_outlined, size: 10, color: AppTheme.textSecondary);
  final lowerPlace = place.toLowerCase();

  if (lowerPlace.contains('netflix')) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.red, width: 0.5),
      ),
      child: Text(
        'N',
        style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  if (lowerPlace.contains('sinema') || lowerPlace.contains('cinema')) {
    return const Icon(Icons.local_activity_rounded, size: 10, color: Colors.amberAccent);
  }

  if (lowerPlace.contains('ev') || lowerPlace.contains('home')) {
    return const Icon(Icons.home_rounded, size: 10, color: Colors.tealAccent);
  }

  if (lowerPlace.contains('prime') || lowerPlace.contains('amazon')) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.blue, width: 0.5),
      ),
      child: Text(
        'a',
        style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  if (lowerPlace.contains('disney')) {
    return const Icon(Icons.star_rounded, size: 10, color: Colors.purpleAccent);
  }

  return const Icon(Icons.location_on_outlined, size: 10, color: AppTheme.textSecondary);
}
