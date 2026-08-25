import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_utils.dart';
import '../../presentation/providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'specialty_selection_screen.dart';
import 'main_container_screen.dart';
import 'study_goal_screen.dart';
import 'forgot_password_screen.dart';
import 'admin/admin_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          final user = Provider.of<AuthProvider>(context, listen: false).user;
          debugPrint('LOGIN DEBUG: User ID: ${user?.id}');
          debugPrint('LOGIN DEBUG: Has Specialties: ${user?.hasSpecialties}');
          debugPrint('LOGIN DEBUG: Has Study Plan: ${user?.hasStudyPlan}');

          // Removed Debug SnackBar

          if (user?.role == 'admin') {
            debugPrint('LOGIN DEBUG: Navigating to AdminScaffold');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminScaffold()),
            );
          } else {
            debugPrint('LOGIN DEBUG: Role is not admin, checking setup');
            if (!(user?.hasSpecialties ?? false)) {
              debugPrint('LOGIN DEBUG: Navigating to SpecialtySelectionScreen');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SpecialtySelectionScreen()),
              );
            } else if (!(user?.hasStudyPlan ?? false)) {
              debugPrint('LOGIN DEBUG: Navigating to CreatePlanScreen');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StudyGoalScreen()),
              );
            } else {
              debugPrint('LOGIN DEBUG: Navigating to MainContainerScreen');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainContainerScreen()),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, e.toString().replaceAll('Exception: ', ''));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo or Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width > 600 ? 120 : 80,
                        height: MediaQuery.of(context).size.width > 600 ? 120 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 600 ? 28 : 20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 600 ? 28 : 20),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.welcomeBack('Doctor'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.login,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  label: l10n.email,
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: l10n.password,
                  hint: '********',
                  isPassword: true,
                  controller: _passwordController,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                CustomButton(
                  text: l10n.signIn,
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style:
                          const TextStyle(color: AppColors.textSecondaryLight),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.signUp,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
