import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/glass_container.dart';

// Shown when ApiConstants.tmdbApiKey is empty — the app falls back to a
// small hardcoded set of demo movies (see tmdb_service.dart's mock data).
class SearchApiKeyWarningBanner extends StatelessWidget {
  const SearchApiKeyWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 12,
        opacity: 0.8,
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'TMDb API anahtarı girilmedi. Şu an deneme modundasınız ("dune", "interstellar", "inception" veya "dark" aramalarını test edebilirsiniz).',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.amber.shade200,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
