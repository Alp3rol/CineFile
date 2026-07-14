import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';

// The blurred backdrop image plus its black fading mask, shown behind the
// scrollable content. Both layers are always present (even when
// backdropPath is null, or opacity has faded to 0) and visibility is
// controlled purely via Opacity — see the comment this replaces in
// movie_detail_screen.dart: keeping this as a single always-present
// Positioned entry in the parent Stack (rather than conditionally
// inserting/removing children) avoids Flutter's unkeyed list
// reconciliation reassigning Element identity mid-scroll, which used to
// reset the ScrollController's position.
class MovieDetailBackdrop extends StatelessWidget {
  final String? backdropPath;
  final double opacity;
  final double width;
  final double height;

  const MovieDetailBackdrop({
    super.key,
    required this.backdropPath,
    required this.opacity,
    required this.width,
    this.height = 480,
  });

  Widget _fadeMask({required Widget child}) {
    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.65, 1.0],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdropPath != null)
          _fadeMask(
            child: AppNetworkImage(
              imageUrl: '${ApiConstants.imagePathW780}$backdropPath',
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        _fadeMask(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
