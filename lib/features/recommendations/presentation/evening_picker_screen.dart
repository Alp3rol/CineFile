import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/tmdb_service.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../movie_detail/domain/watch_provider_models.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/evening_feedback_service.dart';
import '../domain/evening_picker.dart';
import 'recommendations_provider.dart';

class EveningPickerScreen extends ConsumerStatefulWidget {
  const EveningPickerScreen({super.key});

  @override
  ConsumerState<EveningPickerScreen> createState() =>
      _EveningPickerScreenState();
}

class _EveningPickerScreenState extends ConsumerState<EveningPickerScreen> {
  EveningMood _mood = EveningMood.exciting;
  EveningTitleType _type = EveningTitleType.any;
  int _minutes = 120;
  bool _loading = false;
  List<EveningCandidate>? _results;
  List<EveningCandidate> _candidates = const [];
  String? _provider;
  final Set<int> _dismissedIds = {};

  Set<String> get _providers => {
    for (final candidate in _candidates) ...candidate.providerNames,
  };

  Future<void> _find() async {
    setState(() => _loading = true);
    try {
      final recommendations = await ref.read(recommendationsProvider.future);
      final service = ref.read(tmdbServiceProvider);
      final region = ref.read(effectiveWatchRegionProvider);
      final candidates = await Future.wait(
        recommendations.map((item) async {
          try {
            final details = await service.getMovieDetails(
              item.tmdbId,
              isTv: item.isTv,
            );
            final providerData = await service.getWatchProviders(
              item.tmdbId,
              isTv: item.isTv,
            );
            final availability = parseWatchProviders(providerData, region);
            return EveningCandidate(
              item: item,
              runtimeMinutes: (details?['runtime'] as num?)?.toInt(),
              providerNames: {
                for (final providers
                    in availability == null
                        ? const <List<WatchProvider>>[]
                        : availability.byCategory.values)
                  for (final provider in providers) provider.name,
              },
            );
          } catch (_) {
            return EveningCandidate(item: item, runtimeMinutes: null);
          }
        }),
      );
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        if (_provider != null && !_providers.contains(_provider)) {
          _provider = null;
        }
        _applyFilters();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    _results = const EveningPicker().select(
      candidates: _candidates,
      mood: _mood,
      type: _type,
      maxMinutes: _minutes,
      providerName: _provider,
      excludedIds: _dismissedIds,
    );
  }

  Future<void> _feedback(EveningCandidate candidate, bool interested) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(eveningFeedbackServiceProvider)
          .save(candidate.item, isInterested: interested);
      if (!mounted) return;
      setState(() {
        _dismissedIds.add(candidate.item.tmdbId);
        _applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            interested
                ? l10n.eveningFeedbackInterestedSaved
                : l10n.eveningFeedbackDismissedSaved,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eveningFeedbackFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.eveningPickerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.eveningPickerDescription),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.eveningPickerMood,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: EveningMood.values
                .map(
                  (mood) => ChoiceChip(
                    label: Text(_moodLabel(l10n, mood)),
                    selected: _mood == mood,
                    onSelected: (_) => setState(() => _mood = mood),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.eveningPickerType,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<EveningTitleType>(
            segments: [
              ButtonSegment(
                value: EveningTitleType.any,
                label: Text(l10n.eveningPickerAny),
              ),
              ButtonSegment(
                value: EveningTitleType.movie,
                label: Text(l10n.eveningPickerMovie),
              ),
              ButtonSegment(
                value: EveningTitleType.tv,
                label: Text(l10n.eveningPickerTv),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.eveningPickerDuration(_minutes),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _minutes.toDouble(),
            min: 30,
            max: 240,
            divisions: 7,
            label: '$_minutes',
            onChanged: (value) => setState(() => _minutes = value.round()),
          ),
          if (_providers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.eveningPickerPlatform,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String?>(
              initialValue: _provider,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.eveningPickerAnyPlatform),
                ),
                ...(_providers.toList()..sort()).map(
                  (provider) => DropdownMenuItem<String?>(
                    value: provider,
                    child: Text(provider),
                  ),
                ),
              ],
              onChanged: (value) => setState(() {
                _provider = value;
                _applyFilters();
              }),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.eveningPickerFind,
            icon: Icons.auto_awesome_rounded,
            isFullWidth: true,
            isLoading: _loading,
            onPressed: _loading ? null : _find,
          ),
          if (_results != null) ...[
            const SizedBox(height: AppSpacing.xl),
            if (_results!.isEmpty)
              AppEmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.eveningPickerNoResults,
                subtitle: l10n.eveningPickerNoResultsHint,
              )
            else
              ..._results!.map(
                (candidate) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.movie_filter_rounded,
                          color: AppColors.accent,
                        ),
                        title: Text(candidate.item.title),
                        subtitle: Text(
                          '${candidate.item.reason}\n${l10n.eveningPickerReason(_moodLabel(l10n, _mood), candidate.runtimeMinutes ?? _minutes)}',
                        ),
                        isThreeLine: true,
                        trailing: candidate.item.voteAverage > 0
                            ? Text(
                                candidate.item.voteAverage.toStringAsFixed(1),
                              )
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(
                              tmdbId: candidate.item.tmdbId,
                              isTv: candidate.item.isTv,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          0,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              label: Text(l10n.eveningFeedbackInterested),
                              onPressed: () => _feedback(candidate, true),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.block_rounded),
                              label: Text(l10n.eveningFeedbackDismiss),
                              onPressed: () => _feedback(candidate, false),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(l10n.eveningFeedbackAnother),
                              onPressed: () => setState(() {
                                _dismissedIds.add(candidate.item.tmdbId);
                                _applyFilters();
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _moodLabel(AppLocalizations l10n, EveningMood mood) => switch (mood) {
    EveningMood.exciting => l10n.eveningMoodExciting,
    EveningMood.light => l10n.eveningMoodLight,
    EveningMood.thoughtful => l10n.eveningMoodThoughtful,
    EveningMood.emotional => l10n.eveningMoodEmotional,
  };
}
