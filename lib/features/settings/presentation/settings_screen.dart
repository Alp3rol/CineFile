import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/widgets/user_profile_avatar_button.dart';
import '../../../../core/widgets/scroll_to_top_button.dart';
import 'widgets/settings_backup_section.dart';
import 'widgets/settings_credits_footer.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_tmdb_attribution.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky Screen Title & Profile Avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ayarlar',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const UserProfileAvatarButton(),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsPreferencesSection(),
                    const SizedBox(height: 32),

                    const SettingsBackupSection(),
                    const SizedBox(height: 32),

                    const SettingsTmdbAttribution(),
                    const SizedBox(height: 32),

                    const SettingsCreditsFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScrollToTopButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        show: _showScrollToTop,
      ),
    );
  }
}
