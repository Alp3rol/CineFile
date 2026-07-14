import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../core/database/database_provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/presentation/widgets/user_profile_avatar_button.dart';
import 'community_feed_provider.dart';
import 'widgets/community_empty_state.dart';
import 'widgets/community_post_card.dart';
import 'widgets/share_options_sheet.dart';
import 'widgets/user_search_result_tile.dart';
import 'user_search_provider.dart';
import 'user_search_screen.dart';
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

  // Inline user search — mirrors journal_screen.dart's _showSearch pattern:
  // the search icon toggles a search field open in place, never navigating
  // away from the Community feed itself (tapping a result still does, that
  // is a real navigation to a profile, not the search UI).
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // updates the clear-button visibility
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(userSearchQueryProvider.notifier).state = value;
    });
  }

  void _onScroll() {
    final show = _scrollController.offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
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

  // Renders the same three states as UserSearchScreen (empty query / no
  // results / results), but in place of the feed content instead of a
  // pushed route — see _showSearch.
  Widget _buildInlineSearchResults() {
    final resultsAsync = ref.watch(userSearchResultsProvider);
    final query = ref.watch(userSearchQueryProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Hata oluştu: $err',
            style: GoogleFonts.inter(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (results) {
        if (query.trim().isEmpty) {
          return const CommunityEmptyState(
            icon: Icons.person_search_rounded,
            title: 'Kullanıcı Ara',
            subtitle: 'Kullanıcı adına göre arama yapın.',
          );
        }
        if (results.isEmpty) {
          return CommunityEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Kullanıcı Bulunamadı',
            subtitle: '"$query" ile eşleşen bir kullanıcı yok.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) => UserSearchResultTile(user: results[index]),
        );
      },
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
                    Row(
                      children: [
                        // Search toggle button — mirrors journal_screen.dart's
                        // inline search toggle (no separate route).
                        GestureDetector(
                          key: const Key('communitySearchToggle'),
                          onTap: () {
                            setState(() {
                              _showSearch = !_showSearch;
                              if (!_showSearch) {
                                _searchController.clear();
                                _searchDebounce?.cancel();
                                ref.read(userSearchQueryProvider.notifier).state = '';
                              }
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _showSearch ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                              color: _showSearch ? AppTheme.accentColor : Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const UserProfileAvatarButton(),
                      ],
                    ),
                  ],
                ),
              ),

              // Inline search field — shown in place of the tabs/feed below,
              // never pushes a new route (see UserSearchScreen for the
              // full-page variant, still used by the "Kullanıcı Ara" CTA).
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı adına göre ara...',
                      hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),

              // Filter Toggle Tabs
              if (currentUser != null && !_showSearch)
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
              if (currentUser != null && !_showSearch)
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

              if (_showSearch)
                Expanded(child: _buildInlineSearchResults())
              else
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
                        return const CommunityEmptyState(
                          icon: Icons.movie_filter_outlined,
                          title: 'Henüz bir gönderi yok',
                          subtitle: 'Paylaşım kutusunu kullanarak ilk gönderini oluştur!',
                        );
                      }
                      if (followedIds.isEmpty) {
                        return CommunityEmptyState(
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
                      return const CommunityEmptyState(
                        icon: Icons.hourglass_empty_rounded,
                        title: 'Takip ettikleriniz henüz paylaşım yapmadı',
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // extra padding at bottom for navigation bar
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        return CommunityPostCard(post: filteredPosts[index], currentUser: currentUser);
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
