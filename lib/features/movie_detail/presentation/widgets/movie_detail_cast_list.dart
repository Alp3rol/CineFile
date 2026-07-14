import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';

class MovieDetailCastList extends StatelessWidget {
  final List<dynamic>? cast;
  const MovieDetailCastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    final cast = this.cast;
    if (cast == null || cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oyuncular',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length > 8 ? 8 : cast.length,
            itemBuilder: (context, idx) {
              final actor = cast[idx];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    // Avatar Circle
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.surfaceColor,
                      backgroundImage: actor['profile_path'] != null
                          ? NetworkImage('${ApiConstants.imagePathW500}${actor['profile_path']}')
                          : null,
                      child: actor['profile_path'] == null
                          ? const Icon(Icons.person_rounded, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      actor['name'] as String,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
