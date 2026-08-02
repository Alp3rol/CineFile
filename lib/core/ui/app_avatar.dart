import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_network_image.dart';

/// A circular user avatar with an initials fallback.
///
/// Deliberately built on [AppNetworkImage] rather than `CircleAvatar` +
/// `NetworkImage`: that widget already solves per-platform caching and
/// downsampling (see its notes on `memCacheWidth`), and avatars appear in
/// long community lists where decoding at full resolution is exactly the cost
/// it exists to avoid.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSize.avatarMd,
  });

  final String? imageUrl;

  /// Used for the initials fallback and to seed the placeholder colour, so a
  /// given user always gets the same background rather than a new one per
  /// rebuild.
  final String? name;

  final double size;

  String get _initials {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: AppSize.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AppNetworkImage(
              imageUrl: imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              seed: name ?? imageUrl,
            )
          : Center(
              child: Text(
                _initials,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      // Scales with the avatar so one widget covers the 32/44/72
                      // sizes without the caller overriding the text style.
                      fontSize: size * 0.36,
                    ),
              ),
            ),
    );
  }
}
