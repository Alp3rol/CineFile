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
    debugPrint('Initializing Firebase in Dart...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' || e.toString().contains('already exists')) {
      debugPrint('Firebase app already registered.');
    } else {
      debugPrint('FirebaseException during init: $e');
    }
  } catch (e, stack) {
    debugPrint('ERROR during Firebase init: $e');
    debugPrint(stack.toString());
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
        if (kIsWeb) {
          return WebDeviceFrame(child: child!);
        }
        return child!;
      },
      home: const AuthGate(),
    );
  }
}
