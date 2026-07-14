import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/user_profile_avatar_button.dart';
import 'journal_view_mode_toggle.dart';

// "Günlüğüm" title row: search toggle, card/table view toggle, profile avatar.
class JournalTopBanner extends StatelessWidget {
  final bool showSearch;
  final bool isTableView;
  final VoidCallback onToggleSearch;

  const JournalTopBanner({
    super.key,
    required this.showSearch,
    required this.isTableView,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 16, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Günlüğüm',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Row(
            children: [
              // Search toggle button
              GestureDetector(
                onTap: onToggleSearch,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: showSearch ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                    color: showSearch ? AppTheme.accentColor : Colors.white70,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Card/Table view toggle — moved here from filter row
              JournalViewModeToggle(isTableView: isTableView),
              const SizedBox(width: 12),
              // Profile Avatar Button
              const UserProfileAvatarButton(),
            ],
          ),
        ],
      ),
    );
  }
}
