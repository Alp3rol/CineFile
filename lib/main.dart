import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/web_device_frame.dart';
import 'features/auth/presentation/auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('tr_TR', null);

  try {
    debugPrint('Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('Firebase initialized successfully!');
  } catch (e, stack) {
    debugPrint('CRITICAL ERROR during Firebase init: $e');
    debugPrint(stack.toString());

    // Fallback: If Firebase apps is still empty, retry with web options directly
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
        debugPrint('Fallback Firebase init succeeded!');
      } catch (e2) {
        debugPrint('Fallback Firebase init failed: $e2');
      }
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CineFile',
      theme: AppTheme.darkTheme,
      scrollBehavior: CineFileScrollBehavior(),
      builder: (context, child) {
        // Web'de geniş ekranda cihaz seçici frame'i göster
        if (kIsWeb) {
          return WebDeviceFrame(child: child!);
        }
        // Mobilde normal görünüm
        return child!;
      },
      home: const AuthGate(),
    );
  }
}
