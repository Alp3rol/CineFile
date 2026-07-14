import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Handle bar + title + close button for AddWatchRecordSheet. Deliberately
// outside the sheet's scroll view so it stays visible while scrolling
// through the form, AND so a downward drag starting on it isn't captured by
// the inner SingleChildScrollView, letting the sheet's default
// drag-to-dismiss gesture work from here.
class AddWatchRecordHeader extends StatelessWidget {
  final VoidCallback onClose;
  const AddWatchRecordHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günlüğe İzleme Kaydı Ekle',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Explicit close affordance — the sheet's content can grow
              // tall enough (esp. with the TV episode-tracking section) to
              // fill the whole screen, leaving no backdrop to tap and
              // making drag-to-dismiss fight with the inner scroll view.
              // Without this, there was no way to back out without saving.
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
