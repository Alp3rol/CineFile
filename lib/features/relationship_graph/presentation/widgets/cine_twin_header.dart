import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/cine_twin_calculator.dart';

class CineTwinHeader extends StatelessWidget {
  final String userAName;
  final String userBName;
  final CineTwinResult result;

  const CineTwinHeader({
    super.key,
    required this.userAName,
    required this.userBName,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final badge = result.badge;
    final pct = result.matchPercentage;

    return Column(
      children: [
        // Dual Avatar Header with Score Badge in Middle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // User A Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppTheme.accentColor.withValues(alpha: 0.3),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.surfaceColor,
                    child: Text(
                      userAName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userAName,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ],
            ),

            // Score Badge in Center
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor,
                    const Color(0xFFFF5252),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '%$pct',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).cineTwinMatchLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // User B Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.3),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.surfaceColor,
                    child: Text(
                      userBName.replaceAll('@', '').substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userBName,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Persona Badge Glass Container
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badge.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    badge.title(AppLocalizations.of(context)),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                badge.description(AppLocalizations.of(context)),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
