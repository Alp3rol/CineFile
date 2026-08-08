import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinefile/core/l10n/genre_names.dart';
import 'package:cinefile/core/ui/ui.dart';
import 'package:cinefile/core/widgets/glass_container.dart';
import 'package:cinefile/core/widgets/premium_toast.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/insights/presentation/insights_provider.dart';
import 'package:cinefile/l10n/app_localizations.dart';

class CineFileWrappedScreen extends ConsumerStatefulWidget {
  const CineFileWrappedScreen({super.key});

  @override
  ConsumerState<CineFileWrappedScreen> createState() => _CineFileWrappedScreenState();
}

class _CineFileWrappedScreenState extends ConsumerState<CineFileWrappedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  Future<void> _shareSummaryText(BuildContext context, InsightsData insights) async {
    final l10n = AppLocalizations.of(context);
    final hours = (insights.totalDurationMinutes / 60).round();
    final topGenreName = insights.topGenres.isNotEmpty
        ? genreName(l10n, insights.topGenres.first.key)
        : '-';

    final text = '🎬 CineFile Wrapped Özetim\n'
        '• Toplam İzleme Süresi: $hours Saat (${insights.totalWatchCount} yapım)\n'
        '• Ortalama Puan: ${insights.averageRating.toStringAsFixed(1)} ★\n'
        '• En Favori Tür: $topGenreName\n'
        '• En Uzun Seri: ${insights.longestStreak} Gün 🔥\n'
        'CineFile Uygulaması ile kaydedildi';

    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showPremiumToast(context, l10n.wrappedCopiedToast);
    }
  }

  Future<void> _postToCommunity(BuildContext context, InsightsData insights) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final l10n = AppLocalizations.of(context);
    final hours = (insights.totalDurationMinutes / 60).round();
    final topGenreName = insights.topGenres.isNotEmpty
        ? genreName(l10n, insights.topGenres.first.key)
        : '-';

    final content = '📊 CineFile Wrapped Özetim!\n'
        '• $hours Saat izleme (${insights.totalWatchCount} yapım)\n'
        '• Ortalama Puanım: ${insights.averageRating.toStringAsFixed(1)} ★\n'
        '• En Favori Türüm: $topGenreName\n'
        '• En Uzun Serim: ${insights.longestStreak} Gün 🔥';

    try {
      await ref.read(firestoreProvider).collection('posts').add({
        'userId': user.uid,
        'username': user.displayName ?? user.email?.split('@').first ?? 'CineFile Kullanıcısı',
        'userAvatar': user.photoURL ?? '',
        'type': 'text',
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });

      if (context.mounted) {
        showPremiumToast(context, 'Toplulukta başarıyla paylaşıldı! 🚀');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (context.mounted) {
        showPremiumToast(context, 'Paylaşım yapılırken bir hata oluştu.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insights = ref.watch(insightsProvider);

    if (insights == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hours = (insights.totalDurationMinutes / 60).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.25),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Story Progress Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      for (int i = 0; i < 4; i++)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _currentPage ? AppColors.accent : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.wrappedTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Story PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      // Slide 1: Watch Time Highlights
                      _buildSlide1(l10n, insights, hours),

                      // Slide 2: Top Favorites
                      _buildSlide2(l10n, insights),

                      // Slide 3: Habits & Streaks
                      _buildSlide3(l10n, insights),

                      // Slide 4: Summary Card & Share
                      _buildSlide4(context, l10n, insights, hours),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide1(AppLocalizations l10n, InsightsData insights, int hours) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 56, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.wrappedIntro,
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Text(
                  l10n.wrappedTotalHours(hours),
                  style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.accent),
                ),
                Text(
                  l10n.wrappedTotalTime,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                ),
                const Divider(height: 32, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${insights.totalWatchCount}',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text('Yapım', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${insights.averageRating.toStringAsFixed(1)} ★',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                        ),
                        Text('Ortalama', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2(AppLocalizations l10n, InsightsData insights) {
    final topDirector = insights.topDirectors.isNotEmpty ? insights.topDirectors.first.key : '-';
    final topActor = insights.topActors.isNotEmpty ? insights.topActors.first.key : '-';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_filter_rounded, size: 56, color: Colors.purpleAccent),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.wrappedTopGenres,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final entry in insights.topGenres.take(5))
                AppChip(
                  label: '${genreName(l10n, entry.key)} (${entry.value})',
                  selected: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.movie_creation_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.wrappedTopDirector, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        Text(topDirector, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, color: Colors.white10),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.wrappedTopActor, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        Text(topActor, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3(AppLocalizations l10n, InsightsData insights) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 56, color: Colors.orangeAccent),
          const SizedBox(height: AppSpacing.md),
          Text(
            'İzleme Alışkanlıkların',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('${insights.longestStreak}', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                        Text('En Uzun Seri (Gün)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('${insights.mostFrequentRating} ★', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        Text('En Sık Verdiğin Puan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide4(BuildContext context, AppLocalizations l10n, InsightsData insights, int hours) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.movie_rounded, color: AppColors.accent, size: 24),
                    const SizedBox(width: AppSpacing.xs),
                    Text('CineFile Wrapped', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('$hours Saat', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.accent)),
                Text('${insights.totalWatchCount} Film & Dizi İzledin', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                const Divider(height: 32, color: Colors.white10),
                Text('Ortalama Puan: ${insights.averageRating.toStringAsFixed(1)} ★ | Seri: ${insights.longestStreak} Gün', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.wrappedShareCTA,
            icon: Icons.share_rounded,
            variant: AppButtonVariant.primary,
            onPressed: () => _shareSummaryText(context, insights),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.wrappedPostCommunity,
            icon: Icons.people_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => _postToCommunity(context, insights),
          ),
        ],
      ),
    );
  }
}
