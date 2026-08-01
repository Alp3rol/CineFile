import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/ui.dart';
import 'watch_form_label.dart';

// "Aktif İzliyorum" TV episode tracking block (switch + stepper rows +
// manual episode-count entry) used in the add-watch-record sheet. Purely
// presentational — all state and clamp/seed logic stays in the parent, which
// precomputes the enabled/disabled stepper callbacks exactly as before the
// split.
class EpisodeTrackingSection extends StatelessWidget {
  final bool isActivelyWatching;
  final int selectedEpisode;
  final int? totalEpisodes;
  final TextEditingController episodeCountController;
  final bool finishedWholeShow;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFinishedWholeShowChanged;
  final VoidCallback? onEpisodeCountDecrement;
  final VoidCallback? onEpisodeCountIncrement;
  final ValueChanged<String> onEpisodeCountTextChanged;
  final VoidCallback? onSelectedEpisodeDecrement;
  final VoidCallback? onSelectedEpisodeIncrement;

  const EpisodeTrackingSection({
    super.key,
    required this.isActivelyWatching,
    required this.selectedEpisode,
    required this.totalEpisodes,
    required this.episodeCountController,
    required this.finishedWholeShow,
    required this.onActiveChanged,
    required this.onFinishedWholeShowChanged,
    required this.onEpisodeCountDecrement,
    required this.onEpisodeCountIncrement,
    required this.onEpisodeCountTextChanged,
    required this.onSelectedEpisodeDecrement,
    required this.onSelectedEpisodeIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WatchFormLabel(l10n.episodeTrackingActive),
            // Colours come from switchTheme.
            Switch(value: isActivelyWatching, onChanged: onActiveChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isActivelyWatching)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: WatchFormLabel(
                  totalEpisodes != null
                      ? l10n.episodeLabelOf(selectedEpisode, totalEpisodes!)
                      : l10n.episodeLabel(selectedEpisode),
                ),
              ),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: onSelectedEpisodeDecrement,
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$selectedEpisode',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: onSelectedEpisodeIncrement,
                  ),
                ],
              ),
            ],
          )
        else ...[
          // Whether TMDb gave us a total episode count decides if "finished
          // the whole show" is even offerable — without a total there's
          // nothing to mark "finished" against, so fall straight back to the
          // manual episode-count stepper.
          if (totalEpisodes != null)
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: l10n.episodeTrackingWholeSeason,
                    selected: finishedWholeShow,
                    onTap: () => onFinishedWholeShowChanged(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ChoiceButton(
                    label: l10n.episodeTrackingSpecificCount,
                    selected: !finishedWholeShow,
                    onTap: () => onFinishedWholeShowChanged(false),
                  ),
                ),
              ],
            ),
          if (totalEpisodes == null || !finishedWholeShow) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: WatchFormLabel(l10n.episodeTrackingCountLabel),
                ),
                Row(
                  children: [
                    _StepperButton(
                      icon: Icons.remove_rounded,
                      onTap: onEpisodeCountDecrement,
                    ),
                    SizedBox(
                      width: 56,
                      child: TextField(
                        key: const Key('episodeCountField'),
                        controller: episodeCountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: textTheme.titleLarge,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        ),
                        onChanged: onEpisodeCountTextChanged,
                      ),
                    ),
                    _StepperButton(
                      icon: Icons.add_rounded,
                      onTap: onEpisodeCountIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

/// One of the two mutually exclusive "how much did you watch" options.
///
/// Not [AppChip]: these are a segmented choice sized to fill half the row,
/// where a chip hugs its label. The distinction is worth keeping — a chip that
/// stretches stops reading as a chip.
class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: AppOpacity.soft)
              : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          borderRadius: AppRadius.allSm,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: AppSize.hairline,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    selected ? AppColors.accent : AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  static const double _diameter = 28;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    // Disabled reads as the accent at reduced strength rather than as grey:
    // grey_800/grey_700 were two more unnamed neutrals, and a dimmed accent
    // says "this control, unavailable" more clearly than a different colour.
    final tint = isEnabled
        ? AppColors.accent
        : AppColors.accent.withValues(alpha: AppOpacity.muted);

    return AppPressable(
      onTap: onTap,
      borderRadius: AppRadius.pill,
      child: Container(
        width: _diameter,
        height: _diameter,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          shape: BoxShape.circle,
          border: Border.all(color: tint, width: AppSize.hairline),
        ),
        child: Icon(icon, size: AppSize.iconSm, color: tint),
      ),
    );
  }
}
