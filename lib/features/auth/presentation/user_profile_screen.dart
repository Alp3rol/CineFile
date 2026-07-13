import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/database/database_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../community/presentation/widgets/follow_button.dart';
import 'package:image_picker/image_picker.dart';
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
                  if (userModel.bio != null && userModel.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        userModel.bio!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
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
                    FollowButton(targetUserId: effectiveUserId),
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
  bool _isLoading = false;
  bool _isUploadingImage = false;
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploadingImage = true;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 400,
        maxHeight: 400,
      );

      if (pickedFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final downloadUrl = await ref.read(authControllerProvider).uploadAvatarImage(bytes, fileName);
      
      if (downloadUrl != null) {
        setState(() {
          _selectedAvatarUrl = downloadUrl;
          _isUploadingImage = false;
        });
      } else {
        setState(() {
          _isUploadingImage = false;
          _errorMessage = 'Görsel yüklenemedi. Firebase Storage yapılandırmanızı kontrol edin.';
        });
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
        _errorMessage = 'Resim yükleme hatası: $e';
      });
    }
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
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
                  if (_isUploadingImage)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Image Upload and Reset buttons
            Center(
              child: ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Kendi Görselini Yükle'),
              ),
            ),
            const SizedBox(height: 20),

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
                fillColor: Colors.white.withOpacity(0.05),
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
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
              onPressed: (_isLoading || _isUploadingImage) ? null : _saveProfile,
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
