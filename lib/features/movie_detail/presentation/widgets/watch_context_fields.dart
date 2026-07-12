import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nerede İzledin?',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: Kadıköy Sineması, Ev...',
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: suggestions.map((place) {
            return ActionChip(
              label: Text(place, style: GoogleFonts.inter(fontSize: 11)),
              backgroundColor: AppTheme.surfaceColor,
              onPressed: () => onSuggestionTap(place),
            );
          }).toList(),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kiminle İzledin?',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: Tek başıma, Ahmet, Ailem...',
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: suggestions.map((companion) {
            return ActionChip(
              label: Text(companion, style: GoogleFonts.inter(fontSize: 11)),
              backgroundColor: AppTheme.surfaceColor,
              onPressed: () => onSuggestionTap(companion),
            );
          }).toList(),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişisel Notların:',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Film hakkında ne düşünüyorsun? Akılda kalıcı sahneler...',
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özel Etiketler (#tag):',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: #nostalji, #sinemada, #yalnız (Virgülle ayırın)...',
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: suggestions.map((tag) {
            return ActionChip(
              label: Text(tag, style: GoogleFonts.inter(fontSize: 11)),
              backgroundColor: AppTheme.surfaceColor,
              onPressed: () => _onSuggestionTap(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
