import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class ScrollToTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool show;

  const ScrollToTopButton({
    super.key,
    required this.onPressed,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: show ? Offset.zero : const Offset(0, 1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: show ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !show,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80), // Float comfortably above the bottom navigation bar
            child: GestureDetector(
              onTap: onPressed,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassContainer(
                  width: 48,
                  height: 48,
                  borderRadius: 24,
                  opacity: 0.8,
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppTheme.accentColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
