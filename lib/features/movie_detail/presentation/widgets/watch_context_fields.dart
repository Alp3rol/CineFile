import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'watch_form_label.dart';

// Suggestion chips for the fields below, laid out in a single horizontally
// scrollable row (never wraps to a second line) so a long suggestion list
// stays compact instead of pushing the rest of the sheet down.
class _SuggestionChipRow extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionChipRow({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Default (hardEdge) clip — keeps the chip row confined to the
        // sheet's horizontal padding instead of bleeding out to the
        // screen/device edge.
        itemCount: suggestions.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final label = suggestions[index];
          // AppChip rather than a hand-rolled Material + InkWell + Container:
          // these are the same object as the filter chips elsewhere in the
          // app, and were drawn differently only because nothing shared
          // existed.
          return AppChip(label: label, onTap: () => onTap(label));
        },
      ),
    );
  }
}

// "Nerede İzledin?" text field + suggestion chips used in the
// add-watch-record sheet. onSuggestionTap is expected to setState-wrap the
// controller assignment, matching the sheet's original inline behavior.
class WatchPlaceField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const WatchPlaceField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchFormLabel(l10n.addRecordPlaceLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.addRecordPlaceHint),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SuggestionChipRow(suggestions: suggestions, onTap: onSuggestionTap),
      ],
    );
  }
}

// "Kiminle İzledin?" text field + suggestion chips.
class WatchCompanionField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const WatchCompanionField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchFormLabel(l10n.addRecordCompanionLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.addRecordCompanionHint),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SuggestionChipRow(suggestions: suggestions, onTap: onSuggestionTap),
      ],
    );
  }
}

// "Kişisel Notların" notes text field.
class WatchNotesField extends StatelessWidget {
  final TextEditingController controller;

  const WatchNotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchFormLabel(l10n.addRecordNotesLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.addRecordNotesHint),
        ),
      ],
    );
  }
}

// "Özel Etiketler (#tag)" text field + suggestion chips. Note: unlike
// WatchPlaceField/WatchCompanionField, tapping a suggestion here does NOT go
// through setState in the parent (the original sheet mutated
// controller.text directly relying on the TextField's own controller
// listener) — preserve that asymmetry, don't "fix" it.
class WatchTagsField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;

  const WatchTagsField({
    super.key,
    required this.controller,
    required this.suggestions,
  });

  void _onSuggestionTap(String tag) {
    final currentText = controller.text.trim();
    if (currentText.isEmpty) {
      controller.text = tag;
    } else {
      final tagsList = currentText.split(',').map((t) => t.trim()).toList();
      if (!tagsList.contains(tag)) {
        controller.text = '$currentText, $tag';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchFormLabel(l10n.addRecordTagsLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.addRecordTagsHint),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SuggestionChipRow(suggestions: suggestions, onTap: _onSuggestionTap),
      ],
    );
  }
}
