import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';

class ActorProfileHeader extends StatefulWidget {
  final Map<String, dynamic> actor;

  const ActorProfileHeader({super.key, required this.actor});

  @override
  State<ActorProfileHeader> createState() => _ActorProfileHeaderState();
}

class _ActorProfileHeaderState extends State<ActorProfileHeader> {
  bool _isBioExpanded = false;

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Bilinmiyor';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}.${parts[1]}.${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final actor = widget.actor;
    final name = actor['name'] as String? ?? 'Bilinmeyen Oyuncu';
    final profilePath = actor['profile_path'] as String?;
    final birthday = actor['birthday'] as String?;
    final deathday = actor['deathday'] as String?;
    final placeOfBirth = actor['place_of_birth'] as String?;
    final biography = actor['biography'] as String? ?? '';

    final birthInfo = _formatDate(birthday);
    final deathInfo = deathday != null ? _formatDate(deathday) : null;
    final locationInfo = placeOfBirth ?? 'Bilinmiyor';

    return Stack(
      alignment: Alignment.center,
      children: [
        // Radial background glow for avatar depth
        Positioned(
          top: 10,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentColor.withValues(alpha: 0.25),
                  Colors.purple.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // The main card
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Glowing border around Profile Image
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor,
                      Colors.purpleAccent,
                      Colors.blueAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceColor, width: 2.5),
                    image: profilePath != null
                        ? DecorationImage(
                            image: NetworkImage('${ApiConstants.imagePathW500}$profilePath'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profilePath == null
                      ? const Icon(Icons.person_rounded, size: 48, color: Colors.white60)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Actor Name
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Personal info details (Doğum Tarihi, Doğum Yeri vb.)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _infoBadge(Icons.cake_outlined, 'Doğum: $birthInfo'),
                  if (deathInfo != null)
                    _infoBadge(Icons.sentiment_very_dissatisfied_outlined, 'Ölüm: $deathInfo'),
                  _infoBadge(Icons.location_on_outlined, locationInfo),
                ],
              ),

              // Biography Section (If not empty)
              if (biography.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Biyografi',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  biography,
                  maxLines: _isBioExpanded ? null : 4,
                  overflow: _isBioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (biography.length > 200) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBioExpanded = !_isBioExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _isBioExpanded ? 'Daha Az Göster' : 'Devamını Oku',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        Icon(
                          _isBioExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.accentColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
