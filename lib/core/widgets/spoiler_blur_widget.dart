import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that blurs its child to prevent spoilers until tapped.
class SpoilerBlurWidget extends StatefulWidget {
  const SpoilerBlurWidget({
    super.key,
    required this.child,
    this.isBlurredInitially = true,
    this.blurSigma = 8.0,
    this.spoilerLabel = 'Spoiler — Dokun ve Gör',
  });

  final Widget child;
  final bool isBlurredInitially;
  final double blurSigma;
  final String spoilerLabel;

  @override
  State<SpoilerBlurWidget> createState() => _SpoilerBlurWidgetState();
}

class _SpoilerBlurWidgetState extends State<SpoilerBlurWidget> {
  late bool _isBlurred;

  @override
  void initState() {
    super.initState();
    _isBlurred = widget.isBlurredInitially;
  }

  void _toggleBlur() {
    setState(() {
      _isBlurred = !_isBlurred;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleBlur,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isBlurred
            ? Stack(
                key: const ValueKey('spoiler_blurred'),
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.blurSigma,
                      sigmaY: widget.blurSigma,
                    ),
                    child: widget.child,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility_off_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.spoilerLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(
                key: const ValueKey('spoiler_unblurred'),
                child: widget.child,
              ),
      ),
    );
  }
}
