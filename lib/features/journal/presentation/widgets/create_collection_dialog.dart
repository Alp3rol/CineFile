import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/analytics/product_analytics.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/premium_date_picker.dart';
import '../../../settings/presentation/settings_provider.dart';

class CreateCollectionDialog extends ConsumerStatefulWidget {
  final CustomList? list;

  const CreateCollectionDialog({super.key, this.list});

  @override
  ConsumerState<CreateCollectionDialog> createState() =>
      _CreateCollectionDialogState();
}

class _CreateCollectionDialogState
    extends ConsumerState<CreateCollectionDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  DateTime? _selectedTargetDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list?.name ?? '');
    _descController = TextEditingController(
      text: widget.list?.description ?? '',
    );
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
      initialDate:
          _selectedTargetDate ?? DateTime.now().add(const Duration(days: 30)),
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
      final isFirstCollection =
          (ref.read(customListsProvider).value ?? const []).isEmpty;
      await createCustomList(
        ref,
        name,
        _descController.text.trim(),
        targetDate: _selectedTargetDate,
      );
      if (isFirstCollection) {
        await ref
            .read(productAnalyticsProvider)
            .log(ProductEvent.firstCollectionCreated);
      }
      if (mounted) {
        Navigator.pop(context); // Close dialog
      }
    }
  }

  Widget _templateChip(String name, String desc) {
    return ActionChip(
      label: Text(
        name,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
      side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
      onPressed: () {
        setState(() {
          _nameController.text = name;
          _descController.text = desc;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.list != null;
    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        opacity: 0.85,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
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
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.rating.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isEditMode
                      ? Icons.edit_note_rounded
                      : Icons.collections_bookmark_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isEditMode
                  ? AppLocalizations.of(context).collectionEditTitle
                  : AppLocalizations.of(context).collectionCreateTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isEditMode
                  ? AppLocalizations.of(context).collectionEditExplain
                  : AppLocalizations.of(context).collectionCreateExplain,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            // Templates for new collections
            if (!isEditMode) ...[
              Text(
                'Hızlı Şablonlar',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _templateChip(
                      '🏆 Tüm Zamanların En İyileri',
                      'İzlediğim veya izlemek istediğim efsanevi yapımlar.',
                    ),
                    const SizedBox(width: 8),
                    _templateChip(
                      '🍿 Hafta Sonu Maratonu',
                      'Bu hafta sonu izlenecek film ve diziler.',
                    ),
                    const SizedBox(width: 8),
                    _templateChip(
                      '🌌 Bilim Kurgu & Şaşırtıcı Sonlar',
                      'Uzay, zaman yolculuğu ve sürpriz sonlu yapımlar.',
                    ),
                    const SizedBox(width: 8),
                    _templateChip(
                      '🎬 Oscar Ödüllü Başyapıtlar',
                      'Akademi ödüllü sinema eserleri.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Name Field
            TextField(
              controller: _nameController,
              autofocus: !isEditMode,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.bookmark_border_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                hintText: AppLocalizations.of(context).collectionNameHint,
                labelText: AppLocalizations.of(context).collectionNameLabel,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descController,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.notes_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                hintText: AppLocalizations.of(
                  context,
                ).collectionDescriptionHint,
                labelText: AppLocalizations.of(
                  context,
                ).collectionDescriptionLabel,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Marathon Target Date Title
            Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: AppColors.rating,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).collectionTargetDateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Target Date Selection Button
            GestureDetector(
              onTap: _pickTargetDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken.withValues(
                    alpha: AppOpacity.soft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTargetDate != null
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : AppColors.textPrimary.withValues(
                            alpha: AppOpacity.faint,
                          ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _selectedTargetDate != null
                          ? AppColors.accent
                          : AppColors.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedTargetDate == null
                            ? AppLocalizations.of(
                                context,
                              ).collectionTargetDatePick
                            : formatShortDate(context, _selectedTargetDate!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _selectedTargetDate != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: _selectedTargetDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
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
                          color: AppColors.error,
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
                // The confirm button used to carry a fourth distinct primary
                // gradient (accent to accentSubtle), after the home hero's,
                // the detail screen's warm one, and the TV dialog's. All four
                // were the same control.
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.of(context).commonCancel,
                    variant: AppButtonVariant.secondary,
                    isFullWidth: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: isEditMode
                        ? AppLocalizations.of(context).commonSave
                        : AppLocalizations.of(context).commonCreate,
                    isFullWidth: true,
                    onPressed: _saveCollection,
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
