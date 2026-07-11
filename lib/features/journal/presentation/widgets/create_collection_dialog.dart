import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/premium_date_picker.dart';

class CreateCollectionDialog extends ConsumerStatefulWidget {
  final CustomList? list;

  const CreateCollectionDialog({super.key, this.list});

  @override
  ConsumerState<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends ConsumerState<CreateCollectionDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  DateTime? _selectedTargetDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list?.name ?? '');
    _descController = TextEditingController(text: widget.list?.description ?? '');
    _selectedTargetDate = widget.list?.targetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await PremiumDatePicker.show(
      context,
      initialDate: _selectedTargetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  Future<void> _saveCollection() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (widget.list != null) {
      // Edit Mode
      await updateCustomList(
        ref,
        widget.list!.id,
        name,
        _descController.text.trim(),
        targetDate: _selectedTargetDate,
        clearTargetDate: _selectedTargetDate == null,
      );
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Go back from detail screen to refresh
      }
    } else {
      // Create Mode
      await createCustomList(
        ref,
        name,
        _descController.text.trim(),
        targetDate: _selectedTargetDate,
      );
      if (mounted) {
        Navigator.pop(context); // Close dialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.list != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        opacity: 0.85,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Glowing Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.2),
                      AppTheme.ratingColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isEditMode ? Icons.edit_note_rounded : Icons.collections_bookmark_rounded,
                  color: AppTheme.accentColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isEditMode ? 'Koleksiyonu Düzenle' : 'Yeni Koleksiyon Oluştur',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEditMode 
                  ? 'Koleksiyonunuzun adı, açıklaması ve maraton tarihini güncelleyin.'
                  : 'Film maratonlarınızı takip etmek veya tematik listeler oluşturmak için bilgileri girin.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              autofocus: !isEditMode,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.bookmark_border_rounded, color: Colors.white54, size: 20),
                hintText: 'Örn: Marvel Maratonu, Başyapıtlar...',
                labelText: 'Koleksiyon Adı',
                labelStyle: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              maxLines: 2,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.notes_rounded, color: Colors.white54, size: 20),
                hintText: 'Koleksiyonunuza dair kısa bir açıklama yazın...',
                labelText: 'Açıklama (İsteğe Bağlı)',
                labelStyle: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),

            // Marathon Target Date Title
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppTheme.ratingColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Maraton Hedef Tarihi',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Target Date Selection Button
            GestureDetector(
              onTap: _pickTargetDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTargetDate != null
                        ? AppTheme.accentColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _selectedTargetDate != null ? AppTheme.accentColor : Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedTargetDate == null
                            ? 'Hedef Tarih Seçin (İsteğe Bağlı)'
                            : DateFormat('dd.MM.yyyy').format(_selectedTargetDate!),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedTargetDate != null ? Colors.white : Colors.white30,
                          fontWeight: _selectedTargetDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_selectedTargetDate != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTargetDate = null;
                          });
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE8362E), // Cinematic Red
                          Color(0xFFFA584F), // Vibrant Crimson
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveCollection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isEditMode ? 'Kaydet' : 'Oluştur',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
