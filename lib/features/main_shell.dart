import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/glass_container.dart';
import '../core/widgets/dynamic_background_wrapper.dart';
import 'home/presentation/home_screen.dart';
import 'search/presentation/search_screen.dart';
import 'journal/presentation/journal_screen.dart';
import 'calendar/presentation/calendar_screen.dart';
import 'settings/presentation/settings_screen.dart';

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
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainShellTabIndexProvider);
    return DynamicBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Crucial for showing blurred content behind the bottom navigation bar
        body: _screens[selectedIndex],
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
                  _buildNavItem(selectedIndex, 0, Icons.home_rounded, Icons.home_outlined, 'Ana Sayfa'),
                  _buildNavItem(selectedIndex, 1, Icons.search_rounded, Icons.search_outlined, 'Keşfet'),
                  _buildNavItem(selectedIndex, 2, Icons.book_rounded, Icons.book_outlined, 'Günlük'),
                  _buildNavItem(selectedIndex, 3, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Takvim'),
                  _buildNavItem(selectedIndex, 4, Icons.settings_rounded, Icons.settings_outlined, 'Ayarlar'),
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
