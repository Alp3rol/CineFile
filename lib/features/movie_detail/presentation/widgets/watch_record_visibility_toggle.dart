import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// Controls ONLY the "Son İzlediklerim" section on the user's own profile
// screen. Deliberately unrelated to the Community feed: feed posts are
// created explicitly via the compose bar's "Film Paylaş"/"Günlüğünü Paylaş"
// flows (see share_compose_sheet.dart), which snapshot their own data and
// never read this flag.
class WatchRecordVisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const WatchRecordVisibilityToggle({super.key, required this.isPublic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.public_rounded, color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Profilimde Göster',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              Switch(
                value: isPublic,
                activeThumbColor: AppTheme.accentColor,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Açarsan bu kayıt profilindeki "Son İzlediklerim" bölümünde herkese görünür.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
