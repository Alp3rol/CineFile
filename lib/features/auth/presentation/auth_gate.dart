import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Text(
            'Hata oluştu: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
