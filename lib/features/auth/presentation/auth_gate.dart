import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import '../../main_shell.dart';
import '../../../core/theme/app_theme.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          final userModel = ref.watch(userModelProvider);
          if (userModel == null) {
            // We have a firebase user, load their firestore profile.
            Future.microtask(() => ref.read(authControllerProvider).initUser(user));
            return const Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentColor,
                ),
              ),
            );
          }
          return const MainShell();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentColor,
          ),
        ),
      ),
      error: (err, stack) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: AppTheme.accentColor, size: 52),
                  const SizedBox(height: 16),
                  Text(
                    'Bağlantı Başlatılıyor',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Firebase sunucusuna erişim sağlanıyor. Lütfen sayfayı yenileyin veya tekrar deneyin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
                      } catch (_) {}
                      ref.invalidate(authStateProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      'Tekrar Deneyin',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
