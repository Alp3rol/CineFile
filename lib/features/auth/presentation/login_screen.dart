import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/ui.dart';
import '../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  AuthFailure? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final failure = await ref.read(authControllerProvider).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: DynamicBackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthBrandHeader(tagline: l10n.authTagline),
                    const SizedBox(height: AppSpacing.xxl),

                    AuthFormCard(
                      title: l10n.authSignIn,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.authEmailHint,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.authEmailRequired;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return l10n.authEmailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: l10n.authPasswordHint,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.authPasswordRequired;
                            }
                            if (value.trim().length < 6) {
                              return l10n.authPasswordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        if (_error != null) ...[
                          AuthErrorText(message: _error!.message(l10n)),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        AppButton(
                          label: l10n.authSignIn,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AuthSwitchPrompt(
                      prompt: l10n.authNoAccountPrompt,
                      linkLabel: l10n.authSignUpLink,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
