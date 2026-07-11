import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/dynamic_background_wrapper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../auth/presentation/user_profile_screen.dart';
import 'community_feed_provider.dart';
import '../../../core/database/database_provider.dart';
import '../../journal/models/diary_log_model.dart';
import 'widgets/comments_sheet.dart';

enum FeedTab { all, following }
final feedTabProvider = StateProvider<FeedTab>((ref) => FeedTab.all);

class CommunityFeedScreen extends ConsumerWidget {
  const CommunityFeedScreen({super.key});

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  Future<void> _toggleStar(String logId, List<String> starredBy, String currentUserId) async {
    final logRef = FirebaseFirestore.instance.collection('logs').doc(logId);
    
    if (starredBy.contains(currentUserId)) {
      await logRef.update({
        'starredBy': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await logRef.update({
        'starredBy': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  Widget _buildTabButton(WidgetRef ref, FeedTab tab, String label) {
    final activeTab = ref.watch(feedTabProvider);
    final isActive = activeTab == tab;

    return GestureDetector(
      onTap: () => ref.read(feedTabProvider.notifier).state = tab,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.accentColor : Colors.white10,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;
    
    final followedUsersAsync = ref.watch(followedUserIdsProvider);
    final feedTab = ref.watch(feedTabProvider);

    return DynamicBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Title Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Topluluk Akışı',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Filter Toggle Tabs
              if (currentUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildTabButton(ref, FeedTab.all, 'Tümü'),
                      const SizedBox(width: 12),
                      _buildTabButton(ref, FeedTab.following, 'Takip Ettiklerim'),
                    ],
                  ),
                ),
              
              Expanded(
                child: feedAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentColor),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Akış yüklenirken hata oluştu: $err',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  data: (logs) {
                    final followedIds = followedUsersAsync.value ?? {};
                    final filteredLogs = feedTab == FeedTab.all
                        ? logs
                        : logs.where((log) => log.userId == currentUser?.uid || followedIds.contains(log.userId)).toList();

                    if (filteredLogs.isEmpty) {
                      return Center(
                        child: Text(
                          feedTab == FeedTab.all
                              ? 'Henüz paylaşılmış bir günlük bulunmuyor.'
                              : 'Takip ettiğiniz kişilerin henüz bir paylaşımı yok.',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // extra padding at bottom for navigation bar
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final isStarred = currentUser != null && log.starredBy.contains(currentUser.uid);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 20,
                            opacity: 0.65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. User Header Row
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => UserProfileScreen(userId: log.userId),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppTheme.surfaceColor,
                                        backgroundImage: NetworkImage(log.userAvatarUrl),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => UserProfileScreen(userId: log.userId),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              log.username,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatRelativeTime(log.createdAt),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Watch Date / Method Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.history_toggle_off_rounded, color: Colors.white70, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('dd.MM.yyyy').format(log.watchDate),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                
                                // 2. Content Section (Poster + Movie Meta)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Movie Poster
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MovieDetailScreen(
                                              tmdbId: log.movieId,
                                              isTv: log.isTv,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          log.moviePosterPath != null && log.moviePosterPath!.isNotEmpty
                                              ? 'https://image.tmdb.org/t/p/w185${log.moviePosterPath}'
                                              : 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=185',
                                          width: 80,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 80,
                                            height: 120,
                                            color: AppTheme.surfaceColor,
                                            child: const Icon(Icons.movie_rounded, color: Colors.white24),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Movie Metadata
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => MovieDetailScreen(
                                                    tmdbId: log.movieId,
                                                    isTv: log.isTv,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              log.movieTitle,
                                              style: GoogleFonts.outfit(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (log.releaseYear != null)
                                                Text(
                                                  '${log.releaseYear}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                              if (log.releaseYear != null && log.isTv)
                                                const SizedBox(width: 6),
                                              if (log.isTv)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppTheme.accentColor.withOpacity(0.4), width: 0.5),
                                                  ),
                                                  child: Text(
                                                    'Dizi',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.accentColor,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Rating and Mood
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 18),
                                              const SizedBox(width: 4),
                                              Text(
                                                log.rating.toStringAsFixed(1),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '/10',
                                                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Mod: ${log.mood}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          
                                          // Place / Companion details if available
                                          if (log.watchPlace != null || log.watchCompanion != null)
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  if (log.watchPlace != null) ...[
                                                    const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 12),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      log.watchPlace!,
                                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                                    ),
                                                  ],
                                                  if (log.watchPlace != null && log.watchCompanion != null)
                                                    const SizedBox(width: 10),
                                                  if (log.watchCompanion != null) ...[
                                                    const Icon(Icons.people_alt_outlined, color: AppTheme.textSecondary, size: 12),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      log.watchCompanion!,
                                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // 3. User Review / Notes (if present)
                                if (log.notes != null && log.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
                                    ),
                                    child: Text(
                                      '"${log.notes}"',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 14),
                                const Divider(color: Colors.white10, height: 1),
                                const SizedBox(height: 10),
                                
                                // 4. Interactive Bottom Row (Like / Comment Actions)
                                Row(
                                  children: [
                                    // Like/Star Action
                                    GestureDetector(
                                      onTap: () {
                                        if (currentUser == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Beğenmek için lütfen giriş yapın.')),
                                          );
                                          return;
                                        }
                                        _toggleStar(log.id, log.starredBy, currentUser.uid);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isStarred 
                                              ? AppTheme.accentColor.withOpacity(0.15) 
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isStarred 
                                                ? AppTheme.accentColor.withOpacity(0.3) 
                                                : Colors.white12,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                                              color: isStarred ? AppTheme.accentColor : Colors.white60,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${log.starredBy.length}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isStarred ? AppTheme.accentColor : Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Comment Action
                                    GestureDetector(
                                      onTap: () => CommentsSheet.show(context, log.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white12, width: 0.8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: Colors.white60,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${log.commentCount}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
