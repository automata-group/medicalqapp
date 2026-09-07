import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/toast_utils.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String? resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isResending = false;

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0 || _isResending) return;
    setState(() => _isResending = true);

    try {
      final authDataSource = sl<AuthRemoteDataSource>();
      await authDataSource.forgotPassword(widget.email.trim());
      _startCountdown();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ToastUtils.showSuccess(context, l10n.codeResentSuccess);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authDataSource = sl<AuthRemoteDataSource>();
      final otp = _otpController.text.trim();
      final newPassword = _passwordController.text;

      if (widget.resetToken != null && widget.resetToken!.isNotEmpty && otp.isEmpty) {
        await authDataSource.resetPassword(widget.resetToken!, newPassword);
      } else {
        await authDataSource.resetPasswordWithOtp(
          widget.email.trim(),
          otp,
          newPassword,
        );
      }

      if (!mounted) return;
      setState(() => _isSuccess = true);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final raw = e.toString().replaceAll('Exception: ', '');
      String msg = raw;
      if (raw.contains('SAME_AS_OLD_PASSWORD') || raw.contains('السابقة') || raw.contains('previous password')) {
        msg = l10n.sameAsOldPassword;
      } else if (raw.contains('INVALID_OTP') || raw.contains('رمز التحقق غير صحيح') || raw.contains('expired')) {
        msg = l10n.invalidOrExpiredOtp;
      } else if (raw.contains('USER_NOT_FOUND') || raw.contains('غير مسجل') || raw.contains('not registered')) {
        msg = l10n.emailNotFound;
      }
      ToastUtils.showError(context, msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _isSuccess ? _buildSuccessView(l10n) : _buildFormView(l10n),
        ),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.setNewPassword,
            textDirection: Directionality.of(context),
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.enterEmailAndOtp(widget.email),
            textDirection: Directionality.of(context),
            style: const TextStyle(
                fontSize: 14, color: AppColors.textLight, height: 1.5),
          ),
          const SizedBox(height: 28),

          // OTP Code Field
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              labelText: l10n.verificationCode,
              hintText: '------',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                letterSpacing: 8,
                fontSize: 22,
              ),
              prefixIcon:
                  const Icon(Icons.pin_outlined, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.enterVerificationCode;
              if (v.trim().length != 6) return l10n.otpMustBe6Digits;
              return null;
            },
          ),
          const SizedBox(height: 20),

          // New Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: l10n.newPassword,
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textLight),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterPassword;
              if (v.length < 8) return l10n.passwordMinLength;
              if (!v.contains(RegExp(r'[A-Z]'))) {
                return l10n.passwordUppercase;
              }
              if (!v.contains(RegExp(r'[0-9]'))) {
                return l10n.passwordNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: l10n.confirmPassword,
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textLight),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterPassword;
              if (v != _passwordController.text) {
                return l10n.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Live Password Checklist
          _buildPasswordChecklist(l10n),
          const SizedBox(height: 24),

          // Resend Code Row
          Center(
            child: _resendCountdown > 0
                ? Text(
                    l10n.resendCodeIn(_resendCountdown),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : TextButton.icon(
                    onPressed: _isResending ? null : _resendCode,
                    icon: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(
                      l10n.resendCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(l10n.resetPasswordBtn,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordChecklist(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([_passwordController, _confirmController]),
      builder: (context, _) {
        final pass = _passwordController.text;
        final confirm = _confirmController.text;
        final isLengthValid = pass.length >= 8;
        final isUppercaseValid = pass.contains(RegExp(r'[A-Z]'));
        final isNumberValid = pass.contains(RegExp(r'[0-9]'));
        final isMatchValid = pass.isNotEmpty && pass == confirm;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.passwordRequirements,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              _buildChecklistRule(l10n.passwordMinLength, isLengthValid),
              _buildChecklistRule(l10n.passwordUppercase, isUppercaseValid),
              _buildChecklistRule(l10n.passwordNumber, isNumberValid),
              _buildChecklistRule(l10n.passwordsDoNotMatch, isMatchValid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistRule(String text, bool isValid) {
    final color = isValid ? AppColors.success : Colors.grey.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green.shade800 : Colors.grey.shade600,
                fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline,
              color: AppColors.success, size: 52),
        ),
        const SizedBox(height: 28),
        Text(l10n.passwordResetSuccess,
            textDirection: Directionality.of(context),
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight)),
        const SizedBox(height: 12),
        Text(
          l10n.passwordResetSuccessSubtitle,
          textAlign: TextAlign.center,
          textDirection: Directionality.of(context),
          style: const TextStyle(
              fontSize: 15, color: AppColors.textLight, height: 1.6),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(l10n.proceedToLogin,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
