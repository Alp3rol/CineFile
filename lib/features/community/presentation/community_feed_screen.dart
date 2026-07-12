import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/dynamic_background_wrapper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../auth/presentation/user_profile_screen.dart';
import 'community_feed_provider.dart';
import '../models/community_post_model.dart';
import '../../../core/database/database_provider.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/share_options_sheet.dart';
import 'user_search_screen.dart';
import 'user_public_diary_screen.dart';
import 'shared_collection_detail_screen.dart';
import '../../../../core/widgets/scroll_to_top_button.dart';


enum FeedTab { all, following }
final feedTabProvider = StateProvider<FeedTab>((ref) => FeedTab.all);

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
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

  Future<void> _toggleStar(String postId, List<String> starredBy, String currentUserId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (starredBy.contains(currentUserId)) {
      await postRef.update({
        'starredBy': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await postRef.update({
        'starredBy': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  Widget _buildTabButton(FeedTab tab, String label) {
    final activeTab = ref.watch(feedTabProvider);
    final isActive = activeTab == tab;

    return GestureDetector(
      onTap: () => ref.read(feedTabProvider.notifier).state = tab,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.05),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onCta,
    String? ctaLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (onCta != null && ctaLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  ctaLabel,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, CommunityPost post) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UserProfileScreen(userId: post.userId)),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.surfaceColor,
            backgroundImage: NetworkImage(post.userAvatarUrl),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserProfileScreen(userId: post.userId)),
                ),
                child: Text(
                  post.username,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Text(
                _formatRelativeTime(post.createdAt),
                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionRow(BuildContext context, CommunityPost post, bool isStarred, User? currentUser) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Beğenmek için lütfen giriş yapın.')),
              );
              return;
            }
            _toggleStar(post.id, post.starredBy, currentUser.uid);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isStarred ? AppTheme.accentColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isStarred ? AppTheme.accentColor.withValues(alpha: 0.3) : Colors.white12,
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
                  '${post.starredBy.length}',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isStarred ? AppTheme.accentColor : Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => CommentsSheet.show(context, post.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white60, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${post.commentCount}',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(BuildContext context, CommunityPost post, User? currentUser) {
    final isStarred = currentUser != null && post.starredBy.contains(currentUser.uid);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context, post),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(tmdbId: post.movieId!, isTv: post.isTv!),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.moviePosterPath != null && post.moviePosterPath!.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w185${post.moviePosterPath}'
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(tmdbId: post.movieId!, isTv: post.isTv!),
                          ),
                        ),
                        child: Text(
                          post.movieTitle ?? '',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (post.releaseYear != null)
                            Text(
                              '${post.releaseYear}',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          if (post.releaseYear != null && post.isTv == true) const SizedBox(width: 6),
                          if (post.isTv == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 0.5),
                              ),
                              child: Text(
                                'Dizi',
                                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              post.rating!.toStringAsFixed(1),
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text('/10', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                            if (post.mood != null) ...[
                              const SizedBox(width: 12),
                              Text('Mod: ${post.mood}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
              ),
              child: Text(
                '"${post.caption}"',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic, height: 1.4),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            _buildInteractionRow(context, post, isStarred, currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarySnapshotCard(BuildContext context, CommunityPost post, User? currentUser) {
    final isStarred = currentUser != null && post.starredBy.contains(currentUser.uid);
    final previewPosters = post.entries
        .map((e) => e['moviePosterPath'] as String?)
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .take(4)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context, post),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserPublicDiaryScreen(username: post.username, entries: post.entries),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.caption,
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${post.entries.length} film/dizi · Günlüğü gör',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (previewPosters.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 46 + (previewPosters.length - 1) * 16,
                      height: 60,
                      child: Stack(
                        children: [
                          for (var i = 0; i < previewPosters.length; i++)
                            Positioned(
                              left: i * 16,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w185${previewPosters[i]}',
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(width: 40, height: 60, color: AppTheme.surfaceColor),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            _buildInteractionRow(context, post, isStarred, currentUser),
          ],
        ),
      ),
    );
  }

  // Unlike the movie/diary_snapshot cards above (frozen at share time),
  // this one is deliberately LIVE — it watches sharedCollectionProvider so
  // the poster preview/name/description stay current as the owner edits
  // their collection. `data == null` means the owner turned sharing off
  // after this post was created; that's rendered as a graceful notice
  // rather than an error or a crash.
  Widget _buildCollectionCard(BuildContext context, CommunityPost post, User? currentUser) {
    final isStarred = currentUser != null && post.starredBy.contains(currentUser.uid);
    final dataAsync = ref.watch(sharedCollectionProvider(post.collectionRefId!));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        opacity: 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context, post),
            const SizedBox(height: 14),
            dataAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
              ),
              error: (err, stack) => Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
              data: (data) {
                if (data == null) {
                  return Row(
                    children: [
                      Icon(Icons.collections_bookmark_outlined, color: AppTheme.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu koleksiyon artık paylaşılmıyor',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  );
                }

                final name = data['name'] as String? ?? '';
                final movies = (data['movies'] as List<dynamic>? ?? []);
                final previewPosters = movies
                    .map((m) => (m as Map)['posterPath'] as String?)
                    .whereType<String>()
                    .where((p) => p.isNotEmpty)
                    .take(4)
                    .toList();

                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SharedCollectionDetailScreen(collectionRefId: post.collectionRefId!),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.caption,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$name · ${movies.length} film/dizi',
                              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (previewPosters.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 46 + (previewPosters.length - 1) * 16,
                          height: 60,
                          child: Stack(
                            children: [
                              for (var i = 0; i < previewPosters.length; i++)
                                Positioned(
                                  left: i * 16,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w185${previewPosters[i]}',
                                      width: 40,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(width: 40, height: 60, color: AppTheme.surfaceColor),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            _buildInteractionRow(context, post, isStarred, currentUser),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Topluluk Akışı',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_search_rounded, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Filter Toggle Tabs
              if (currentUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildTabButton(FeedTab.all, 'Tümü'),
                      const SizedBox(width: 12),
                      _buildTabButton(FeedTab.following, 'Takip Ettiklerim'),
                    ],
                  ),
                ),

              // Compose Bar — deliberately not an editable text field (see
              // ShareOptionsSheet doc comment: no freeform empty posts).
              // Tapping anywhere opens the structured share picker.
              if (currentUser != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => ShareOptionsSheet.show(context),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      borderRadius: 16,
                      opacity: 0.5,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.surfaceColor,
                            backgroundImage: ref.watch(userModelProvider)?.avatarUrl != null
                                ? NetworkImage(ref.watch(userModelProvider)!.avatarUrl!)
                                : null,
                            child: ref.watch(userModelProvider)?.avatarUrl == null
                                ? const Icon(Icons.person_rounded, color: Colors.white70, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bir şeyler paylaş...',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                          const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentColor, size: 22),
                        ],
                      ),
                    ),
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
                  data: (posts) {
                    final followedIds = followedUsersAsync.value ?? {};
                    final filteredPosts = feedTab == FeedTab.all
                        ? posts
                        : posts.where((post) => post.userId == currentUser?.uid || followedIds.contains(post.userId)).toList();

                    if (filteredPosts.isEmpty) {
                      if (feedTab == FeedTab.all) {
                        return _buildEmptyState(
                          icon: Icons.movie_filter_outlined,
                          title: 'Henüz bir gönderi yok',
                          subtitle: 'Paylaşım kutusunu kullanarak ilk gönderini oluştur!',
                        );
                      }
                      if (followedIds.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.person_search_rounded,
                          title: 'Henüz kimseyi takip etmiyorsunuz',
                          subtitle: 'Yeni kişiler keşfedin',
                          ctaLabel: 'Kullanıcı Ara',
                          onCta: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                            );
                          },
                        );
                      }
                      return _buildEmptyState(
                        icon: Icons.hourglass_empty_rounded,
                        title: 'Takip ettikleriniz henüz paylaşım yapmadı',
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // extra padding at bottom for navigation bar
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        switch (post.type) {
                          case 'diary_snapshot':
                            return _buildDiarySnapshotCard(context, post, currentUser);
                          case 'collection':
                            return _buildCollectionCard(context, post, currentUser);
                          default:
                            return _buildMovieCard(context, post, currentUser);
                        }
                      },
                    );
                  },
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
      ),
    );
  }
}
