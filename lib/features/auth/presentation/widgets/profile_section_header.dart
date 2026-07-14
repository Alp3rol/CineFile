import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  const ProfileSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
