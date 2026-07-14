import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileSheet({super.key, required this.user});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
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
