import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class CommunityEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onCta;
  final String? ctaLabel;

  const CommunityEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onCta,
    this.ctaLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (onCta != null && ctaLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  ctaLabel!,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
