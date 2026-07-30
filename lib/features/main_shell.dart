import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/dynamic_background_provider.dart';
import '../core/widgets/glass_container.dart';
import '../core/widgets/dynamic_background_wrapper.dart';
import 'home/presentation/home_screen.dart';
import 'search/presentation/search_screen.dart';
import 'journal/presentation/journal_screen.dart';
import 'community/presentation/community_feed_screen.dart';
import 'relationship_graph/presentation/relationship_graph_screen.dart';
import '../core/services/notification_service.dart';
import '../core/database/database_provider.dart';
import 'settings/presentation/settings_provider.dart';

// Lets other screens (e.g. Home's "Tümünü Gör" buttons) switch the active
// bottom-nav tab without needing a BuildContext-based navigation route.
final mainShellTabIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    JournalScreen(),
    CommunityFeedScreen(),
    RelationshipGraphScreen(),
  ];

  /// Tabs the user has actually opened.
  ///
  /// The body used to be `_screens[selectedIndex]`, which threw the whole
  /// subtree away on every tab change: scroll position, search text and filter
  /// selections were lost, and — because Riverpod 3 pauses a provider once
  /// nothing listens to it — each of that tab's Firestore listeners was torn
  /// down and re-established, paying for a full snapshot again on the way back.
  ///
  /// A plain IndexedStack fixes that but builds all five children up front,
  /// which is worse in a different way: RelationshipGraphScreen would start
  /// fetching credits for every watched title at launch, for a tab the user may
  /// never open. Building a tab only once it has been visited keeps both
  /// properties — nothing is built early, nothing is discarded afterwards.
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifications = ref.read(notificationServiceProvider);
      await notifications.initialize();
      await notifications.syncNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainShellTabIndexProvider);
    // Recorded here rather than in the tap handler so a tab switched to from
    // elsewhere (Home's "Tümünü Gör" buttons write the provider directly) is
    // also marked. Adding to a set is idempotent and schedules no rebuild of
    // its own — this build is already running because the index changed.
    _visitedTabs.add(selectedIndex);

    // Clear dynamic background when switching to tabs that don't use it (Journal, Calendar, Settings)
    ref.listen<int>(mainShellTabIndexProvider, (previous, next) {
      if (next == 2 || next == 3 || next == 4) {
        ref.read(dynamicBackgroundProvider.notifier).clearColors();
      }
    });

    // Re-sync notifications when settings change. Debounced and
    // fingerprint-checked inside the service: this listener fires on every
    // movie_settings write, including the one behind each quick-add "+", and a
    // full rebuild costs two TMDb requests per actively-watched show.
    ref.listen(allMovieSettingsProvider, (prev, next) {
      if (next.hasValue) {
        ref.read(notificationServiceProvider).requestSync();
      }
    });

    // Toggling the preference is a deliberate user action, so it takes effect
    // immediately and bypasses the fingerprint check.
    ref.listen(releaseRemindersEnabledProvider, (prev, next) {
      if (next != prev) {
        ref.read(notificationServiceProvider).syncNotifications(force: true);
      }
    });

    return DynamicBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Crucial for showing blurred content behind the bottom navigation bar
        body: IndexedStack(
          index: selectedIndex,
          children: [
            for (var i = 0; i < _screens.length; i++)
              if (_visitedTabs.contains(i)) _screens[i] else const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassContainer(
              height: 68,
              borderRadius: 24,
              opacity: 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(selectedIndex, 0, Icons.home_rounded, Icons.home_outlined, AppLocalizations.of(context).navHome),
                  _buildNavItem(selectedIndex, 1, Icons.search_rounded, Icons.search_outlined, AppLocalizations.of(context).navDiscover),
                  _buildNavItem(selectedIndex, 2, Icons.book_rounded, Icons.book_outlined, AppLocalizations.of(context).navDiary),
                  _buildNavItem(selectedIndex, 3, Icons.people_rounded, Icons.people_outline_rounded, AppLocalizations.of(context).navCommunity),
                  _buildNavItem(selectedIndex, 4, Icons.hub_rounded, Icons.hub_outlined, AppLocalizations.of(context).navGraph),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int selectedIndex, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => ref.read(mainShellTabIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                size: isSelected ? 24 : 22,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
