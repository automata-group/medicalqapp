import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/auth_hero_panel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLengthValid => _passwordController.text.length >= 8;
  bool get _isUppercaseValid => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _isNumberValid => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _isMatchValid =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text;

  bool get _isPasswordValid =>
      _isLengthValid && _isUppercaseValid && _isNumberValid && _isMatchValid;

  void _showAccountAlreadyExistsDialog(String email) {
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
            const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.accountAlreadyExistsTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 420),
          child: Text(
            l10n.accountAlreadyExistsMessage,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForgotPasswordScreen(
                    initialEmail: _emailController.text.trim(),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.goToForgotPassword, style: const TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.goToLogin, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPasswordValid) {
      final l10n = AppLocalizations.of(context)!;
      ToastUtils.showError(context, l10n.passwordRequirements);
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(
        _nameController.text.trim(),
        email,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        if (errorMsg.contains('مسجل') || errorMsg.contains('already') || errorMsg.contains('EXIST')) {
          _showAccountAlreadyExistsDialog(email);
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

  Widget _buildChecklistRule(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? AppColors.success : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? AppColors.success : Colors.grey.shade600,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final registerSubtitle = isArabic
        ? 'أهلاً بك يا دكتور، أنشئ حسابك للبدء في التحضير'
        : 'Welcome Doctor, create your account to get started';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 700;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding Showcase Side (Full Bleed Hero)
                Expanded(
                  flex: 5,
                  child: AuthHeroPanel(
                    customTitle: isArabic ? 'انضم إلى نخبة الأطباء' : 'Join Elite Medical Doctors',
                    customSubtitle: isArabic
                        ? 'سجل حسابك الآن وابدأ التدريب الفعلي بأحدث الأسئلة والشروحات المعتمدة لاختبار الهيئة'
                        : 'Create your account now and practice with up-to-date verified questions for the Saudi Licensing Exam',
                  ),
                ),

                // Form Side (Full Bleed Spacious Panel)
                Expanded(
                  flex: 6,
                  child: Container(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 36.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (Navigator.of(context).canPop())
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        alignment: AlignmentDirectional.centerStart,
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                        color: AppColors.primary,
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  Text(
                                    l10n.createAccount,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    registerSubtitle,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildFormFields(context, l10n, isDark),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile View
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Navigator.of(context).canPop())
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: AlignmentDirectional.centerStart,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.primary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createAccount,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registerSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildFormFields(context, l10n, isDark),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        CustomTextField(
          label: l10n.fullName,
          hint: l10n.fullNameHint,
          controller: _nameController,
          prefixIcon: const Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.fieldRequired;
            }
            if (value.trim().length < 3) {
              return l10n.nameTooShort;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomTextField(
          label: l10n.email,
          hint: 'doctor@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.fieldRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value.trim())) {
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
            if (value.length < 8) {
              return l10n.passwordMinLength;
            }
            if (!value.contains(RegExp(r'[A-Z]'))) {
              return l10n.passwordUppercase;
            }
            if (!value.contains(RegExp(r'[0-9]'))) {
              return l10n.passwordNumber;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        CustomTextField(
          label: l10n.confirmPassword,
          hint: '••••••••',
          isPassword: _obscureConfirm,
          controller: _confirmPasswordController,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.fieldRequired;
            }
            if (value != _passwordController.text) {
              return l10n.passwordsDoNotMatch;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Password Checklist Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.passwordRequirements,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              _buildChecklistRule(l10n.passwordMinLength, _isLengthValid),
              _buildChecklistRule(l10n.passwordUppercase, _isUppercaseValid),
              _buildChecklistRule(l10n.passwordNumber, _isNumberValid),
              _buildChecklistRule(l10n.passwordsDoNotMatch, _isMatchValid),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Register Button
        CustomButton(
          text: l10n.createAccount,
          onPressed: _submit,
          isLoading: _isLoading,
        ),

        const SizedBox(height: 24),

        // Social Auth Buttons (Google & Apple)
        const SocialAuthButtons(),

        const SizedBox(height: 24),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.alreadyHaveAccount,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.signIn,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
