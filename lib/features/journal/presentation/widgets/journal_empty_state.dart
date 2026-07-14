import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class JournalEmptyState extends StatelessWidget {
  final String activeFilter;
  final String searchQuery;
  const JournalEmptyState({super.key, required this.activeFilter, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            activeFilter != 'all' ? Icons.search_off_rounded : Icons.menu_book_rounded,
            size: 56,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Kayıt Bulunamadı',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Text(
              activeFilter != 'all' || searchQuery.isNotEmpty
                  ? 'Arama kriterlerinize veya filtrelere uyan bir günlük kaydı bulunmamaktadır.'
                  : 'Günlüğünüz henüz boş. Keşfet sekmesinden yeni izleme kayıtları ekleyebilirsiniz.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
