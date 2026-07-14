import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Collapsible search field shown under JournalScreen's tab bar when the
// search icon in the top banner is toggled on.
class JournalSearchField extends StatelessWidget {
  final bool visible;
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const JournalSearchField({
    super.key,
    required this.visible,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 0),
      secondChild: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
        child: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Film, yönetmen, not, mekan...',
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                    onPressed: onClear,
                  )
                : null,
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      crossFadeState: visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }
}
