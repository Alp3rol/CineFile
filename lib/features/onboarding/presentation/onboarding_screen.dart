import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/analytics/product_analytics.dart';
import '../../../core/constants/watch_regions.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/ui/ui.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../main_shell.dart';
import '../../settings/presentation/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.isModal = false});

  final bool isModal;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    } else {
      unawaited(_finishOnboarding());
    }
  }

  Future<void> _finishOnboarding() async {
    final user = ref.currentUser;
    if (user != null) {
      await ref.read(firestoreProvider).collection('users').doc(user.uid).set({
        'onboardingCompleted': true,
      }, SetOptions(merge: true));
      final model = ref.read(userModelProvider);
      if (model != null) {
        ref.read(userModelProvider.notifier).state = model.copyWith(
          onboardingCompleted: true,
        );
      }
    }
    // Kept for the first-session checklist and native backwards compatibility.
    await ref.read(onboardingCompletedProvider.notifier).setCompleted(true);
    await ref
        .read(productAnalyticsProvider)
        .log(ProductEvent.onboardingCompleted);
    if (!mounted) return;

    if (widget.isModal) {
      Navigator.of(context).pop();
    } else {
      unawaited(
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell())),
      );
    }
  }

  Future<void> _toggleFavorite(
    int tmdbId,
    bool isTv,
    bool currentFavorite,
  ) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final settingsRef = ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${tmdbId}_$isTv');

      await settingsRef.set({
        'movieId': tmdbId,
        'isTv': isTv,
        'isFavorite': !currentFavorite,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Toggling favourite in onboarding failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          l10n.appTitle,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_currentPage < 2)
            TextButton(
              onPressed: () => unawaited(_finishOnboarding()),
              child: Text(
                l10n.onboardingSkip,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentPage;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPreferencesStep(context, l10n),
                _buildFavoritesStep(context, l10n),
                _buildWalkthroughStep(context, l10n),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2
                            ? l10n.onboardingFinish
                            : l10n.onboardingNext,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Preferences (Language & Watch Region)
  // ---------------------------------------------------------------------------
  Widget _buildPreferencesStep(BuildContext context, AppLocalizations l10n) {
    final currentLocale = ref.watch(localeProvider);
    final currentRegion = ref.watch(watchRegionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingStepPreferences,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingTitleWelcome,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSubtitleWelcome,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Language Picker Section
          Text(
            l10n.settingsLanguageLabel,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChoiceChip(
                label: 'Türkçe',
                isSelected: currentLocale?.languageCode == 'tr',
                onTap: () => unawaited(
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('tr')),
                ),
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: 'English',
                isSelected: currentLocale?.languageCode == 'en',
                onTap: () => unawaited(
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en')),
                ),
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: l10n.settingsLanguageSystem,
                isSelected: currentLocale == null,
                onTap: () => unawaited(
                  ref.read(localeProvider.notifier).setLocale(null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Watch Region Section
          Text(
            'İzleme Bölgesi / Watch Region',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yayın platformu sağlayıcılarını (Netflix, Prime vb.) doğru görmek için bölgenizi seçin.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Automatic',
                isSelected: currentRegion == null,
                onTap: () => unawaited(
                  ref.read(watchRegionProvider.notifier).setRegion(null),
                ),
              ),
              ...['TR', 'US', 'DE', 'GB', 'FR'].map((code) {
                final label = watchRegionLabel(code);
                return _buildChoiceChip(
                  label: '$code ($label)',
                  isSelected: currentRegion == code,
                  onTap: () => unawaited(
                    ref.read(watchRegionProvider.notifier).setRegion(code),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.accent : Colors.white,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Initial Favorites Search & Quick Add
  // ---------------------------------------------------------------------------
  Widget _buildFavoritesStep(BuildContext context, AppLocalizations l10n) {
    final tmdbService = ref.read(tmdbServiceProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingStepFavorites,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onboardingFavoritesSubtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.onboardingFavoritesSearchHint,
                  hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _searchQuery.isEmpty
                ? tmdbService.getTrendingMoviesThisWeek()
                : tmdbService.searchMovies(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'Sonuç bulunamadı',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildItemTile(items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    final tmdbId = (item['id'] as num?)?.toInt() ?? 0;
    final isTv = item['media_type'] == 'tv';
    final title = (item['title'] ?? item['name'] ?? 'Untitled').toString();
    final posterPath = (item['poster_path'] ?? '').toString();
    final releaseDate = (item['release_date'] ?? item['first_air_date'] ?? '')
        .toString();
    final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

    final key = (tmdbId: tmdbId, isTv: isTv);
    final settingsAsync = ref.watch(movieSettingsSnapshotProvider(key));
    final isFav = settingsAsync.value?.isFavorite ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: posterPath.isNotEmpty
              ? Image.network(
                  '${ApiConstants.imagePathW185}$posterPath',
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 60,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.movie_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Container(
                  width: 40,
                  height: 60,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.movie_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${year.isNotEmpty ? year : ''} ${isTv ? "• Dizi" : "• Film"}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? AppColors.accent : Colors.white54,
          ),
          onPressed: () => unawaited(_toggleFavorite(tmdbId, isTv, isFav)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Feature & Privacy Showcase Walkthrough
  // ---------------------------------------------------------------------------
  Widget _buildWalkthroughStep(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingStepTour,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sinema Günlüğün Hazır',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          _buildFeatureCard(
            icon: Icons.local_movies_rounded,
            title: l10n.onboardingFeature1Title,
            description: l10n.onboardingFeature1Desc,
          ),
          const SizedBox(height: 14),

          _buildFeatureCard(
            icon: Icons.insights_rounded,
            title: l10n.onboardingFeature2Title,
            description: l10n.onboardingFeature2Desc,
          ),
          const SizedBox(height: 14),

          _buildFeatureCard(
            icon: Icons.security_rounded,
            title: l10n.onboardingFeature3Title,
            description: l10n.onboardingFeature3Desc,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
