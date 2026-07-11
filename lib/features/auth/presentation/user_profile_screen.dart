import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/database/database_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../controllers/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String? userId;
  const UserProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;
    
    final effectiveUserId = userId ?? currentUser?.uid;

    if (effectiveUserId == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Text(
            'Lütfen giriş yapın.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final userModelAsync = ref.watch(userModelStreamProvider(effectiveUserId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: userModelAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Hata: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (userModel) {
            if (userModel == null) {
              return const Center(
                child: Text(
                  'Kullanıcı bulunamadı.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final isMe = currentUser != null && currentUser.uid == effectiveUserId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // User Avatar
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentColor, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(
                            userModel.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${userModel.username}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    '@${userModel.username}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    userModel.email,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Row (Followers / Following)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Takipçi', '${userModel.followerCount}'),
                      Container(height: 30, width: 1, color: AppTheme.borderColor),
                      _buildStatColumn('Takip', '${userModel.followingCount}'),
                    ],
                  ),
                  
                  // Follow / Unfollow Button
                  if (!isMe && currentUser != null) ...[
                    const SizedBox(height: 24),
                    ref.watch(isFollowingProvider(effectiveUserId)).when(
                      loading: () => const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: AppTheme.accentColor, strokeWidth: 2),
                      ),
                      error: (err, stack) => const SizedBox(),
                      data: (isFollowing) => GestureDetector(
                        onTap: () async {
                          final followDocRef = FirebaseFirestore.instance
                              .collection('follows')
                              .doc('${currentUser.uid}_$effectiveUserId');

                          final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
                          final targetUserRef = FirebaseFirestore.instance.collection('users').doc(effectiveUserId);

                          final batch = FirebaseFirestore.instance.batch();

                          if (isFollowing) {
                            batch.delete(followDocRef);
                            batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
                            batch.update(targetUserRef, {'followerCount': FieldValue.increment(-1)});
                          } else {
                            batch.set(followDocRef, {
                              'followerId': currentUser.uid,
                              'followingId': effectiveUserId,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
                            batch.update(targetUserRef, {'followerCount': FieldValue.increment(1)});
                          }

                          await batch.commit();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isFollowing ? Colors.transparent : AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isFollowing ? Colors.white24 : AppTheme.accentColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isFollowing ? 'Takibi Bırak' : 'Takip Et',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),

                  // Son İzlediklerim Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son İzlediklerim',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ref.watch(watchRecordsForUserProvider(effectiveUserId)).when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                    error: (err, stack) => Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
                    data: (records) {
                      if (records.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Henüz hiç izleme kaydı eklenmemiş.',
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        );
                      }
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.67,
                        ),
                        itemCount: records.length > 6 ? 6 : records.length,
                        itemBuilder: (context, index) {
                          final item = records[index];
                          final posterPath = item.movie.posterPath;
                          final rating = item.record.rating;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailScreen(
                                    tmdbId: item.movie.tmdbId,
                                    isTv: item.movie.isTv,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      posterPath != null && posterPath.isNotEmpty
                                          ? 'https://image.tmdb.org/t/p/w185$posterPath'
                                          : 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=185',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppTheme.surfaceColor,
                                        child: const Icon(Icons.movie_rounded, color: Colors.white24),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 10),
                                        const SizedBox(width: 2),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  if (isMe) ...[
                    const SizedBox(height: 32),
                    // Profile Actions
                    GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline_rounded, color: Colors.white70),
                            title: const Text('Profili Düzenle (Yakında)'),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                            onTap: () {
                              // TODO: Implement profile edit
                            },
                          ),
                          const Divider(color: AppTheme.borderColor),
                          ListTile(
                            leading: const Icon(Icons.logout_rounded, color: AppTheme.accentColor),
                            title: const Text(
                              'Çıkış Yap',
                              style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.surfaceColor,
                                  title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                                  content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.accentColor)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                Navigator.of(context).pop();
                                await ref.read(authControllerProvider).signOut();
                              }
                            },
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
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
