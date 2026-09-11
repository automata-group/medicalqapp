import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/utils/toast_utils.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/specialty_provider.dart';
import '../screens/admin/admin_scaffold.dart';
import '../screens/main_container_screen.dart';
import '../screens/specialty_selection_screen.dart';
import '../screens/study_goal_screen.dart';

class SocialAuthButtons extends StatefulWidget {
  final Function(bool)? onLoadingStateChanged;

  const SocialAuthButtons({
    super.key,
    this.onLoadingStateChanged,
  });

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  void _navigateToDestination(BuildContext context, UserModel user) {
    if (!context.mounted) return;

    if (user.role == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminScaffold()),
      );
    } else {
      context.read<DashboardProvider>().loadDashboardData();
      context.read<SpecialtyProvider>().loadUserSpecialties();

      if (!user.hasSpecialties) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SpecialtySelectionScreen()),
        );
      } else if (!user.hasStudyPlan) {
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

  Future<void> _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGoogleLoading = true);
    widget.onLoadingStateChanged?.call(true);

    try {
      final user = await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
      if (user != null && mounted) {
        _navigateToDestination(context, user);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        if (!msg.contains('CANCELLED') && !msg.contains('canceled')) {
          ToastUtils.showError(context, l10n.googleSignInFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        widget.onLoadingStateChanged?.call(false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isAppleLoading = true);
    widget.onLoadingStateChanged?.call(true);

    try {
      final user = await Provider.of<AuthProvider>(context, listen: false).signInWithApple();
      if (user != null && mounted) {
        _navigateToDestination(context, user);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        if (!msg.contains('canceled') && !msg.contains('CANCELLED')) {
          ToastUtils.showError(context, l10n.appleSignInFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
        widget.onLoadingStateChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final buttonBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Column(
      children: [
        // Divider with label
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orContinueWith,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Social Buttons Row
        Row(
          children: [
            // Google Sign In Button
            Expanded(
              child: OutlinedButton(
                onPressed: (_isGoogleLoading || _isAppleLoading) ? null : _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isGoogleLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Apple Sign In Button
            Expanded(
              child: OutlinedButton(
                onPressed: (_isGoogleLoading || _isAppleLoading) ? null : _handleAppleSignIn,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF000000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isAppleLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple, size: 22, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Apple',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
