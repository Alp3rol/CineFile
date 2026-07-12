import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/web_device_frame.dart';
import 'features/auth/presentation/auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
  } catch (e, stack) {
    debugPrint('CRITICAL ERROR during Firebase init: $e');
    debugPrint(stack.toString());
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
