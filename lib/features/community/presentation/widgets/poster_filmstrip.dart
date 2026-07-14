import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// The premium film-strip preview shown on both "diary_snapshot" and
// "collection" post cards (was duplicated identically in both — now
// shared). Larger, non-overlapping posters in a horizontally scrollable
// row, with a "+N" tile at the end when there are more entries than fit.
// Each poster still grows/lifts/gains a shadow on hover (desktop/web
// mouse) or press (touch — there's no touch equivalent of hover, so this
// is the substitute). The press feedback uses Listener (raw pointer
// events), not a GestureDetector: Listener doesn't enter the gesture
// arena, so it can't intercept the tap that the existing GestureDetector
// each card wraps this in relies on to navigate.
class PosterFilmstrip extends StatefulWidget {
  final List<String> posterPaths;
  final int remainingCount;
  const PosterFilmstrip({super.key, required this.posterPaths, this.remainingCount = 0});

  @override
  State<PosterFilmstrip> createState() => _PosterFilmstripState();
}

class _PosterFilmstripState extends State<PosterFilmstrip> {
  int? _hoveredIndex;

  static const _posterWidth = 64.0;
  static const _posterHeight = 96.0;
  static const _gap = 8.0;
  static const _hoverLift = 6.0;
  static const _hoverScale = 1.08;
  static const _animationDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final posters = widget.posterPaths;

    return SizedBox(
      height: _posterHeight + _hoverLift,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // lets a hovered/pressed poster lift above the row
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < posters.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Padding(
                padding: EdgeInsets.only(top: _hoveredIndex == i ? 0 : _hoverLift),
                child: Listener(
                  onPointerDown: (_) => setState(() => _hoveredIndex = i),
                  onPointerUp: (_) => setState(() => _hoveredIndex = null),
                  onPointerCancel: (_) => setState(() => _hoveredIndex = null),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = i),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: AnimatedScale(
                      duration: _animationDuration,
                      curve: Curves.easeOut,
                      scale: _hoveredIndex == i ? _hoverScale : 1.0,
                      child: AnimatedContainer(
                        duration: _animationDuration,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _hoveredIndex == i
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : const [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w185${posters[i]}',
                            width: _posterWidth,
                            height: _posterHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: _posterWidth, height: _posterHeight, color: AppTheme.surfaceColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.remainingCount > 0) ...[
              const SizedBox(width: _gap),
              Padding(
                padding: const EdgeInsets.only(top: _hoverLift),
                child: Container(
                  width: _posterWidth,
                  height: _posterHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+${widget.remainingCount}',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
