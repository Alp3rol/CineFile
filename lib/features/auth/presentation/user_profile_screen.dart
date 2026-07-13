import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/database/database_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../community/presentation/widgets/follow_button.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Glassmorphic Profile Card with Gradient Backdrop Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial background glow for avatar depth
                      Positioned(
                        top: 20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.accentColor.withValues(alpha: 0.25),
                                Colors.purple.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // The main card
                      GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Stack(
                          children: [
                            if (isMe)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                                  onPressed: () => _showEditProfileSheet(context, ref, userModel),
                                  tooltip: 'Profili Düzenle',
                                ),
                              ),
                            Column(
                              children: [
                                // Glowing border around Avatar
                                Container(
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentColor,
                                        Colors.purpleAccent,
                                        Colors.blueAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.surfaceColor, width: 2.5),
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
                                // Username with modern Outfit styling
                                Text(
                                  '@${userModel.username}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (userModel.bio != null && userModel.bio!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      userModel.bio!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                // Stats inside capsule row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPremiumStatCapsule('Takipçi', '${userModel.followerCount}'),
                                    const SizedBox(width: 16),
                                    _buildPremiumStatCapsule('Takip', '${userModel.followingCount}'),
                                  ],
                                ),
                                // Follow / Unfollow Button within the header card
                                if (!isMe && currentUser != null) ...[
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FollowButton(targetUserId: effectiveUserId),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Favori Vitrinim Section
                  ref.watch(watchRecordsForUserProvider(effectiveUserId)).when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (records) {
                      final featuredRecords = records
                          .where((r) => userModel.featuredMovieIds.contains('${r.movie.tmdbId}'))
                          .toList();

                      if (featuredRecords.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Favori Vitrinim'),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.015),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.03),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: _FeaturedMoviesStack(featuredRecords: featuredRecords),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),

                  // Son İzlediklerim Section
                  _buildSectionHeader('Son İzlediklerim'),
                  const SizedBox(height: 16),

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
                                      color: Colors.black.withValues(alpha: 0.75),
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
                            title: const Text('Profili Düzenle'),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                            onTap: () => _showEditProfileSheet(context, ref, userModel),
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

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditProfileSheet(user: user);
      },
    );
  }


  Widget _buildPremiumStatCapsule(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;
  const _EditProfileSheet({required this.user});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late String _selectedAvatarUrl;
  late List<String> _tempFeaturedMovieIds;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _presetAvatars = const [
    'https://api.dicebear.com/7.x/bottts/png?seed=cine1',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine2',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine3',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine4',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine5',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine6',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine7',
    'https://api.dicebear.com/7.x/bottts/png?seed=cine8',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _selectedAvatarUrl = widget.user.avatarUrl ?? _presetAvatars.first;
    _tempFeaturedMovieIds = List<String>.from(widget.user.featuredMovieIds);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profili Düzenle',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Avatar Preview
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentColor, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(_selectedAvatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Predefined Avatars section
            Text(
              'Hazır Avatarlar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetAvatars.length,
                itemBuilder: (context, index) {
                  final presetUrl = _presetAvatars[index];
                  final isSelected = _selectedAvatarUrl == presetUrl;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarUrl = presetUrl;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.accentColor : Colors.transparent,
                            width: 2.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(presetUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Username field
            Text(
              'Kullanıcı Adı',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kullanıcı adı girin',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bio field
            Text(
              'Biyografi',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Kendinden bahset...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Featured Movies section
            Text(
              'Profil Vitrini (En Fazla 5 Öne Çıkan Film)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showFeaturedMoviesSelector,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
              ),
              icon: const Icon(Icons.star_rounded, color: AppTheme.accentColor),
              label: Text('Öne Çıkarılan Filmleri Seç (${_tempFeaturedMovieIds.length}/5)'),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeaturedMoviesSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final recordsAsync = ref.watch(watchRecordsForUserProvider(widget.user.id));
            return recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
              error: (err, stack) => AlertDialog(
                backgroundColor: AppTheme.surfaceColor,
                content: Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (records) {
                return StatefulBuilder(
                  builder: (context, setDialogState) {
                    return AlertDialog(
                      backgroundColor: AppTheme.surfaceColor,
                      title: Text(
                        'Öne Çıkarılacak Filmleri Seç',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child: records.isEmpty
                            ? const Center(
                                child: Text(
                                  'Henüz hiç izleme kaydınız yok.',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              )
                            : ListView.builder(
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final item = records[index];
                                  final tmdbIdStr = '${item.movie.tmdbId}';
                                  final isSelected = _tempFeaturedMovieIds.contains(tmdbIdStr);
                                  return CheckboxListTile(
                                    title: Text(
                                      item.movie.title,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      item.movie.isTv ? 'Dizi' : 'Film',
                                      style: const TextStyle(color: Colors.white60),
                                    ),
                                    activeColor: AppTheme.accentColor,
                                    checkColor: Colors.black,
                                    value: isSelected,
                                    onChanged: (bool? checked) {
                                      if (checked == true) {
                                        if (_tempFeaturedMovieIds.length >= 5) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('En fazla 5 film seçebilirsiniz.'),
                                            ),
                                          );
                                          return;
                                        }
                                        setDialogState(() {
                                          _tempFeaturedMovieIds.add(tmdbIdStr);
                                        });
                                      } else {
                                        setDialogState(() {
                                          _tempFeaturedMovieIds.remove(tmdbIdStr);
                                        });
                                      }
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam', style: TextStyle(color: AppTheme.accentColor)),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      setState(() => _errorMessage = 'Kullanıcı adı boş olamaz.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(authControllerProvider).updateProfile(
      username: username,
      avatarUrl: _selectedAvatarUrl,
      bio: bio,
      featuredMovieIds: _tempFeaturedMovieIds,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi.')),
        );
      }
    }
  }
}

class _FeaturedMoviesStack extends StatefulWidget {
  final List<dynamic> featuredRecords;
  const _FeaturedMoviesStack({required this.featuredRecords});

  @override
  State<_FeaturedMoviesStack> createState() => _FeaturedMoviesStackState();
}

class _FeaturedMoviesStackState extends State<_FeaturedMoviesStack> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.featuredRecords.isEmpty) return const SizedBox.shrink();

    final records = widget.featuredRecords;
    final totalCount = records.length;

    final renderIndices = List<int>.generate(totalCount, (index) => index);
    
    if (_hoveredIndex != null && _hoveredIndex! < totalCount) {
      renderIndices.remove(_hoveredIndex);
      renderIndices.add(_hoveredIndex!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        const double cardWidth = 120.0;
        const double cardHeight = 180.0;
        
        // Calculate overlap spacing dynamically to fit perfectly inside the parent container without overflow
        final double spacing = totalCount > 1 
            ? ((availableWidth - cardWidth - 24) / (totalCount - 1)).clamp(30.0, 60.0)
            : 0.0;

        final double stackWidth = totalCount > 1 
            ? cardWidth + (totalCount - 1) * spacing 
            : cardWidth;

        return SizedBox(
          height: 220,
          width: stackWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: renderIndices.map((i) {
              final item = records[i];
              final posterPath = item.movie.posterPath;
              final isHovered = _hoveredIndex == i;

              return AnimatedPositioned(
                key: ValueKey('${item.movie.tmdbId}_$i'),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack, // Premium spring curve for a high-end feel
                left: i * spacing + (isHovered ? 5.0 : 0.0),
                top: isHovered ? 5.0 : 25.0,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = i),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: GestureDetector(
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
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: isHovered ? 1.15 : 1.0,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isHovered 
                                  ? AppTheme.accentColor.withValues(alpha: 0.35) 
                                  : Colors.black.withValues(alpha: 0.45),
                              blurRadius: isHovered ? 20 : 8,
                              offset: Offset(0, isHovered ? 10 : 4),
                            ),
                          ],
                          border: Border.all(
                            color: isHovered ? AppTheme.accentColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            posterPath != null && posterPath.isNotEmpty
                                ? 'https://image.tmdb.org/t/p/w342$posterPath'
                                : 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=342',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.surfaceColor,
                              child: const Icon(Icons.movie_rounded, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
