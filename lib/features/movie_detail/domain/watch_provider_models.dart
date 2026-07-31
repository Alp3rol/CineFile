/// Where a title can legally be watched, per TMDb's watch-provider data
/// (which TMDb sources from JustWatch — see the attribution their terms
/// require, rendered by MovieDetailWatchProvidersSection).
///
/// The API answers for every country at once and offers no region filter, so
/// everything here is about reducing one country's slice of that payload to
/// something a widget can render directly.
library;

/// A single streaming/rental service.
class WatchProvider {
  const WatchProvider({
    required this.providerId,
    required this.name,
    required this.logoPath,
    required this.displayPriority,
  });

  final int providerId;
  final String name;

  /// TMDb image path (`/xxxx.jpg`), or null for the rare provider with no
  /// artwork. Callers prefix it with an `ApiConstants.imagePath*` base.
  final String? logoPath;

  /// TMDb's own ordering hint — lower sorts first. Not globally unique.
  final int displayPriority;

  static WatchProvider? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = (json['provider_id'] as num?)?.toInt();
    final name = (json['provider_name'] as String?)?.trim();
    if (id == null || name == null || name.isEmpty) return null;
    return WatchProvider(
      providerId: id,
      name: name,
      logoPath: json['logo_path'] as String?,
      displayPriority: (json['display_priority'] as num?)?.toInt() ?? 0,
    );
  }

  // Identity is the provider id: the free/ads merge below dedupes on it, and
  // the same service can appear in both lists with different priorities.
  @override
  bool operator ==(Object other) =>
      other is WatchProvider && other.providerId == providerId;

  @override
  int get hashCode => providerId.hashCode;
}

/// How a title is offered. TMDb's `ads` bucket is folded into [free] — from
/// the user's side both mean "no extra payment", and separating them would
/// produce two headings that answer the same question.
enum WatchProviderCategory { flatrate, free, rent, buy }

/// One country's availability for one title.
class WatchAvailability {
  const WatchAvailability({
    required this.region,
    required this.link,
    required this.byCategory,
  });

  final String region;

  /// TMDb's own "watch" page for this title and region. There is exactly ONE
  /// link per region — not one per provider — so anything built on it must not
  /// suggest it leads to a specific service.
  final String? link;

  /// Only non-empty categories are present, so a caller can iterate entries
  /// without having to guard against rendering a heading with nothing under it.
  final Map<WatchProviderCategory, List<WatchProvider>> byCategory;

  bool get isEmpty => byCategory.isEmpty;
}

const _categorySourceKeys = <WatchProviderCategory, List<String>>{
  WatchProviderCategory.flatrate: ['flatrate'],
  // See WatchProviderCategory.free.
  WatchProviderCategory.free: ['free', 'ads'],
  WatchProviderCategory.rent: ['rent'],
  WatchProviderCategory.buy: ['buy'],
};

/// Reduces TMDb's all-countries `results` map to [region]'s slice.
///
/// Returns null when the region isn't in the payload, which is the common case
/// rather than an error: a title carried in thirty countries is absent from the
/// other eighty, and an obscure one comes back with `results: {}`.
///
/// Deliberately a free function over plain JSON so it can be tested without a
/// container, a network stub or a widget.
WatchAvailability? parseWatchProviders(Map<String, dynamic> results, String region) {
  final forRegion = results[region];
  if (forRegion is! Map) return null;

  final byCategory = <WatchProviderCategory, List<WatchProvider>>{};
  for (final entry in _categorySourceKeys.entries) {
    final providers = <WatchProvider>[];
    for (final key in entry.value) {
      final raw = forRegion[key];
      if (raw is! List) continue;
      for (final item in raw) {
        final provider = WatchProvider.fromJson(item);
        // Deduped by provider id: a service legitimately appears under both
        // `free` and `ads`, and listing it twice looks like a bug.
        if (provider != null && !providers.contains(provider)) {
          providers.add(provider);
        }
      }
    }
    if (providers.isEmpty) continue;
    // Name is the tiebreak so the order is deterministic — display_priority
    // collides often, and a test asserting order needs a stable answer.
    providers.sort((a, b) {
      final byPriority = a.displayPriority.compareTo(b.displayPriority);
      return byPriority != 0 ? byPriority : a.name.compareTo(b.name);
    });
    byCategory[entry.key] = providers;
  }

  if (byCategory.isEmpty) return null;
  return WatchAvailability(
    region: region,
    link: forRegion['link'] as String?,
    byCategory: byCategory,
  );
}
