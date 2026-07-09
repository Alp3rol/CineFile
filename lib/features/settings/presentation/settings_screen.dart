import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Visual-only preferences: the app is always dark-themed and Turkish-only
  // today, so these don't change any actual behavior yet. They exist so the
  // "Tercihler" section matches the reference design; wire them up to real
  // functionality if/when light theme, trailers, or i18n are added.
  bool _darkModeEnabled = true;
  bool _autoPlayTrailer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Text(
                'Ayarlar',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 24),

              // 1. Preferences Section
              _buildSectionHeader('Tercihler'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 4),
                borderRadius: 16,
                opacity: 0.6,
                child: Column(
                  children: [
                    _buildToggleRow(
                      icon: Icons.dark_mode_rounded,
                      label: 'Karanlık Mod',
                      value: _darkModeEnabled,
                      onChanged: (v) => setState(() => _darkModeEnabled = v),
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Otomatik Fragman Oynat',
                      value: _autoPlayTrailer,
                      onChanged: (v) => setState(() => _autoPlayTrailer = v),
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      icon: Icons.palette_outlined,
                      label: 'Dinamik Arka Plan',
                      value: ref.watch(dynamicBackgroundEnabledProvider),
                      onChanged: (v) => ref.read(dynamicBackgroundEnabledProvider.notifier).setEnabled(v),
                    ),
                    _buildDivider(),
                    _buildNavRow(
                      icon: Icons.language_rounded,
                      label: 'Dil',
                      trailingText: 'Türkçe',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Diğer diller yakında eklenecek.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Data Management Section
              _buildSectionHeader('Veri Yönetimi & Yedekleme'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                opacity: 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Yedekleme',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tüm izleme geçmişinizi, favorilerinizi ve notlarınızı JSON formatında yedekleyebilir ve istediğiniz cihazda geri yükleyebilirsiniz.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Export Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppTheme.borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text(
                              'Dışa Aktar',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _exportBackup(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Import Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accentColor,
                              side: const BorderSide(color: AppTheme.accentColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.upload_rounded, size: 18),
                            label: Text(
                              'Geri Yükle',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _showImportDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // TMDB Atıf Bölümü
              _buildSectionHeader('Veri Sağlayıcı'),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                opacity: 0.6,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/tmdb_logo.png',
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bu uygulama TMDB API\'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Info/Credits Area
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.movie_filter_rounded,
                      size: 40,
                      color: AppTheme.accentColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CineFile',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Sürüm 0.9.2 (Beta Yayını)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Created with ❤️ by Antigravity & USER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borderColor);
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
            Text(
              trailingText,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }

  // Export process
  Future<void> _exportBackup(BuildContext context) async {
    try {
      final dataMap = await BackupService.exportData(ref);
      final jsonString = const JsonEncoder.withIndent('  ').convert(dataMap);
      
      // Copy to Clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        // Show backup display modal
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Yedek Panoya Kopyalandı!',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yedekleme verileriniz kopyalandı. Bu veriyi bir dosyaya kaydederek veya başka bir cihaza göndererek saklayabilirsiniz.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        jsonString,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kapat',
                    style: GoogleFonts.outfit(color: AppTheme.accentColor),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yedekleme dosyası oluşturulurken hata: $e')),
        );
      }
    }
  }

  // Import Dialog
  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Yedekten Geri Yükle',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daha önce kopyaladığınız JSON yedek kodunu aşağıdaki alana yapıştırın. Bu işlem mevcut yerel verilerinizin üzerine yazacaktır!',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'JSON kodunu buraya yapıştırın...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final input = controller.text.trim();
                if (input.isEmpty) return;

                try {
                  final jsonMap = jsonDecode(input) as Map<String, dynamic>;
                  await BackupService.importData(ref, jsonMap);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verileriniz yedekten başarıyla yüklendi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: Geçersiz yedek kodu formatı! ($e)'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Yükle',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
