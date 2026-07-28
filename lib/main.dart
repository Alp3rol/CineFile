import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/navigation/app_navigator.dart';
import 'core/platform/firebase_web_registrar.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/web_device_frame.dart';
import 'features/auth/presentation/auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Completes once Firebase is ready; [MyApp] shows a spinner until it does and
/// a retry screen if it fails.
///
/// Typed `void` rather than `FirebaseApp` because no consumer uses the app
/// handle — and a plain "is it ready" signal is something a test can override
/// with `(ref) async {}`, which a `FirebaseApp` return type made impossible.
final firebaseInitProvider = FutureProvider<void>((ref) async {
  registerFirebaseWebPlugins();
  if (Firebase.apps.isNotEmpty) return;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('tr_TR', null);

  registerFirebaseWebPlugins();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CineFile',
      theme: AppTheme.darkTheme,
      scrollBehavior: CineFileScrollBehavior(),
      builder: (context, child) {
        if (kIsWeb) {
          return WebDeviceFrame(child: child!);
        }
        return child!;
      },
      home: firebaseInit.when(
        data: (_) => const AuthGate(),
        loading: () => const Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor),
          ),
        ),
        error: (err, stack) => Scaffold(
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
                    'Firebase servislerine erişim sağlanıyor. Lütfen tekrar deneyin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(firebaseInitProvider),
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
        ),
      ),
    );
  }
}
