import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_utils.dart';
import '../../presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/specialty_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'main_container_screen.dart';
import 'study_goal_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import 'admin/admin_scaffold.dart';
import '../widgets/social_auth_buttons.dart';

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showUnverifiedAccountDialog(String email) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        actionsOverflowButtonSpacing: 8,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.accountNotVerifiedTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 420),
          child: Text(
            l10n.accountNotVerifiedMessage,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmailVerificationScreen(email: email),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.verifyNow, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          final user = Provider.of<AuthProvider>(context, listen: false).user;
          debugPrint('LOGIN DEBUG: User ID: ${user?.id}');

          if (user?.role == 'admin') {
            debugPrint('LOGIN DEBUG: Navigating to AdminScaffold');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminScaffold()),
            );
          } else {
            context.read<DashboardProvider>().loadDashboardData();
            context.read<SpecialtyProvider>().loadUserSpecialties();

            if (user?.hasStudyPlan == false) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StudyGoalScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainContainerScreen()),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          final errorMsg = e.toString().replaceAll('Exception: ', '');
          if (errorMsg.contains('غير مفعّل') || errorMsg.contains('NOT_VERIFIED') || errorMsg.contains('verification')) {
            _showUnverifiedAccountDialog(_emailController.text.trim());
          } else if (errorMsg.contains('USER_NOT_FOUND') || errorMsg.contains('غير مسجل') || errorMsg.contains('not registered')) {
            ToastUtils.showError(context, l10n.emailNotFound);
          } else if (errorMsg.contains('INVALID_PASSWORD') || errorMsg.contains('كلمة المرور غير صحيحة') || errorMsg.contains('Incorrect password')) {
            ToastUtils.showError(context, l10n.invalidPassword);
          } else if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup') || errorMsg.contains('connection')) {
            ToastUtils.showError(context, l10n.networkError);
          } else {
            ToastUtils.showError(context, errorMsg);
          }
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
                  hint: '••••••••',
                  isPassword: _obscurePassword,
                  controller: _passwordController,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),

                // Forgot Password
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(
                            initialEmail: _emailController.text.trim(),
                          ),
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

                // Social Auth Buttons (Google & Apple)
                const SocialAuthButtons(),

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
