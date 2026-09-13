import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../core/utils/toast_utils.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    try {
      final authDataSource = sl<AuthRemoteDataSource>();
      await authDataSource.forgotPassword(email);
      if (!mounted) return;
      setState(() => _emailSent = true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final raw = e.toString().replaceAll('Exception: ', '');
      String msg = raw;
      if (raw.contains('USER_NOT_FOUND') || raw.contains('غير مسجل') || raw.contains('not registered')) {
        msg = l10n.emailNotFound;
      } else if (raw.contains('SocketException') || raw.contains('Failed host lookup') || raw.contains('connection')) {
        msg = l10n.networkError;
      }
      ToastUtils.showError(context, msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _emailSent ? _buildSuccessView(l10n, isDark) : _buildFormView(l10n, isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.forgotPassword,
            textDirection: Directionality.of(context),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.forgotPasswordSubtitle,
            textDirection: Directionality.of(context),
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              labelText: l10n.emailAddress,
              labelStyle: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              prefixIcon:
                  const Icon(Icons.email_outlined, color: AppColors.primary),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterEmail;
              if (!v.contains('@')) return l10n.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      l10n.sendResetLink,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.primary),
              label: Text(
                l10n.backToLogin,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.checkYourEmail,
            textDirection: Directionality.of(context),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.weSentResetLink(_emailController.text),
            textAlign: TextAlign.center,
            textDirection: Directionality.of(context),
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // Go to Enter Code Screen
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(email: _emailController.text.trim()),
                ),
              ),
              icon: const Icon(Icons.pin_outlined, size: 20),
              label: Text(l10n.enterVerificationCode,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend
          OutlinedButton.icon(
            onPressed: () => setState(() => _emailSent = false),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.didntReceiveEmail),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.primary),
            label: Text(
              l10n.backToLogin,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
