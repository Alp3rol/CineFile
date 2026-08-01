import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/ui.dart';
import '../../../core/widgets/dynamic_background_wrapper.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  AuthFailure? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Resolved before the await so the success SnackBar below isn't reading
    // from a context that may have been deactivated in the meantime.
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final failure = await ref.read(authControllerProvider).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (failure != null) {
        setState(() {
          _error = failure;
        });
      } else {
        // Pop back to login screen on successful signup, or let the AuthState changes handle it
        Navigator.of(context).pop();
        // Chrome comes from snackBarTheme. The previous hardcoded green
        // background put white text on a light fill; the message itself
        // carries the success, so the themed surface is both readable and
        // consistent with every other snackbar in the app.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authRegisterSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: DynamicBackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthBrandHeader(tagline: l10n.authTagline),
                    const SizedBox(height: AppSpacing.xxl),

                    AuthFormCard(
                      title: l10n.authSignUp,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.authUsernameLabel,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.authUsernameRequired;
                            }
                            if (value.trim().length < 3) {
                              return l10n.authUsernameTooShort;
                            }
                            if (RegExp(r'\s').hasMatch(value)) {
                              return l10n.authUsernameNoSpaces;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

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
                          label: l10n.authSignUp,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AuthSwitchPrompt(
                      prompt: l10n.authHasAccountPrompt,
                      linkLabel: l10n.authSignInLink,
                      onTap: () => Navigator.of(context).pop(),
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
