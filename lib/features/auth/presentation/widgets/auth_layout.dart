import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';

/// Shared furniture for the sign-in and sign-up screens.
///
/// The two screens were about 90% identical markup — the same brand header,
/// the same glass form card, the same "already have an account?" row, each
/// written out twice. Two copies of a layout is how a design drifts: a change
/// lands in one and not the other. These three widgets are the parts that were
/// genuinely duplicated; the forms themselves stay in their own screens
/// because their fields and validation differ.

/// App mark, wordmark and tagline, stacked.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, required this.tagline});

  final String tagline;

  /// Larger than any step in [AppSize] — this is a one-off brand mark rather
  /// than an interface icon, so it does not belong on the icon scale.
  static const double _markSize = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Icon(
          Icons.movie_filter_rounded,
          size: _markSize,
          color: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'CineFile',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// The glass panel holding an auth form, with its heading.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

/// An inline error message inside an auth form.
class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      // Was the brand accent, which happened to be red. An error is a status,
      // not a brand moment — and if the accent ever stops being red, an error
      // styled with it stops reading as an error.
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: AppColors.error),
    );
  }
}

/// The "no account yet? / already have one?" row at the foot of both screens.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onTap,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: Theme.of(context).textTheme.bodyMedium),
        // A TextButton rather than the bare GestureDetector this replaces: the
        // old link's tap target was only as tall as the text (~17px), well
        // under the 44px minimum, and it gave no press feedback at all.
        TextButton(onPressed: onTap, child: Text(linkLabel)),
      ],
    );
  }
}
