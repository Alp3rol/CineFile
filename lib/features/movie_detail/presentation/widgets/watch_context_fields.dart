import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// Shared pill-shaped suggestion chip for the fields below, laid out in a
// single horizontally scrollable row (never wraps to a second line) so a
// long suggestion list stays compact instead of pushing the rest of the
// sheet down.
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
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = suggestions[index];
          return Material(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onTap(label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ),
            ),
          );
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        _SuggestionChipRow(suggestions: suggestions, onTap: _onSuggestionTap),
      ],
    );
  }
}
