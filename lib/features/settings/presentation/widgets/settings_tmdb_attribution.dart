import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import 'settings_section_header.dart';

class SettingsTmdbAttribution extends StatelessWidget {
  const SettingsTmdbAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Veri Sağlayıcı'),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          opacity: 0.6,
          child: Column(
            children: [
              Image.asset(
                'assets/images/tmdb_logo.png',
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                'Bu uygulama TMDB API\'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
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
