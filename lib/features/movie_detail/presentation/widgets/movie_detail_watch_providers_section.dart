import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/watch_provider_models.dart';
import '../watch_providers_provider.dart';

/// "Where can I watch this?" — the streaming services carrying this title in
/// the user's region, grouped by how they offer it.
///
/// Sits above the cast list: it is the one actionable thing on the screen, and
/// below the cast it would end up under the episode guide on a TV show.
class MovieDetailWatchProvidersSection extends ConsumerWidget {
  const MovieDetailWatchProvidersSection({
    super.key,
    required this.tmdbId,
    required this.isTv,
  });

  final int tmdbId;
  final bool isTv;

  /// Fixed order, cheapest-to-the-user first.
  static const _categoryOrder = [
    WatchProviderCategory.flatrate,
    WatchProviderCategory.free,
    WatchProviderCategory.rent,
    WatchProviderCategory.buy,
  ];

  String _categoryLabel(AppLocalizations l10n, WatchProviderCategory category) {
    switch (category) {
      case WatchProviderCategory.flatrate:
        return l10n.detailWatchCategoryFlatrate;
      case WatchProviderCategory.free:
        return l10n.detailWatchCategoryFree;
      case WatchProviderCategory.rent:
        return l10n.detailWatchCategoryRent;
      case WatchProviderCategory.buy:
        return l10n.detailWatchCategoryBuy;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability =
        ref.watch(watchProvidersProvider((tmdbId: tmdbId, isTv: isTv))).value;

    // Loading, failed, not available in this region and no providers anywhere
    // all collapse to "render nothing". This is a supplementary section: it
    // must never be able to break or visibly stall the detail screen, and the
    // cast list takes the same position. `AsyncValue.value` is null rather
    // than throwing on error, which is what swallows a failure here —
    // getWatchProviders still throws, so a test can see it.
    if (availability == null || availability.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.detailWhereToWatch, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final category in _categoryOrder)
          if (availability.byCategory[category] case final providers?) ...[
            Text(
              _categoryLabel(l10n, category),
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            SizedBox(
              // Logo (52) + gap (6) + two lines of 10pt label. Tight enough to
              // stay compact, and the label below is Flexible so a larger
              // system text scale shrinks it instead of overflowing.
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: providers.length,
                itemBuilder: (context, index) => _ProviderTile(provider: providers[index]),
              ),
            ),
            const SizedBox(height: 12),
          ],
        Text(
          l10n.detailWatchProvidersJustWatchAttribution,
          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.provider});

  final WatchProvider provider;

  static const double _logoSize = 52;

  @override
  Widget build(BuildContext context) {
    final logoPath = provider.logoPath;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: _logoSize,
              height: _logoSize,
              // Light backing on purpose. Many provider logos are dark artwork
              // on a transparent background — dropped straight onto this app's
              // dark surfaces, several major services render as an invisible
              // smudge.
              color: const Color(0xFFF3F3F5),
              child: logoPath == null || logoPath.isEmpty
                  ? _InitialFallback(name: provider.name)
                  : AppNetworkImage(
                      imageUrl: '${ApiConstants.imagePathW185}$logoPath',
                      width: _logoSize,
                      height: _logoSize,
                      fit: BoxFit.contain,
                      seed: provider.name,
                      placeholder: const SizedBox.shrink(),
                      errorWidget: _InitialFallback(name: provider.name),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              provider.name,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown for the rare provider with no artwork, and when a logo fails to load.
class _InitialFallback extends StatelessWidget {
  const _InitialFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
