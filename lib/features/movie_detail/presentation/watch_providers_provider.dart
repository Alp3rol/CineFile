import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/tmdb_service.dart';
import '../../settings/presentation/settings_provider.dart';
import '../domain/watch_provider_models.dart';

/// Where a title can be watched in the user's region, or null when it isn't
/// available there (or couldn't be loaded).
///
/// Fetched lazily and separately rather than folded into [movieDetailProvider]
/// via `append_to_response`. That would work, but TMDb returns all 111
/// countries with no way to filter, which inflates the detail response by ~41%
/// — and that request is what the user is staring at a spinner for after
/// tapping a title. This one can arrive a moment later without anybody
/// noticing.
///
/// The region is watched rather than being part of the family key: changing it
/// in Settings then refreshes every live instance without widening the key, and
/// since the underlying response is identical for every region, the refetch is
/// served from Dio's cache instead of the network.
final watchProvidersProvider =
    FutureProvider.family<WatchAvailability?, ({int tmdbId, bool isTv})>((ref, arg) async {
  final region = ref.watch(effectiveWatchRegionProvider);
  final tmdbService = ref.watch(tmdbServiceProvider);

  final results = await tmdbService.getWatchProviders(arg.tmdbId, isTv: arg.isTv);
  return parseWatchProviders(results, region);
});
