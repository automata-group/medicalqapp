import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/dashboard_provider.dart';
import '../../presentation/providers/specialty_provider.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_container_screen.dart';
import 'admin/admin_scaffold.dart';
import 'specialty_selection_screen.dart';
import 'study_goal_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait at least 2.5 seconds to show the branded splash screen
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      SharedPreferences.getInstance(),
      authProvider.tryAutoLogin(),
    ]);

    final bool isAuthenticated = results[2] as bool;

    if (!mounted) return;

    // Aggressively pre-fetch dashboard data if authenticated
    if (isAuthenticated) {
      context.read<DashboardProvider>().loadDashboardData();
      context.read<SpecialtyProvider>().loadSpecialties();
    }

    final prefs = results[1] as SharedPreferences;
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!onboardingDone) {
      // First launch: show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final navigator = Navigator.of(context);

    if (isAuthenticated) {
      final user = authProvider.user;
      final selectedIdsJson = prefs.getString('cached_selected_specialty_ids');
      final bool hasSelectedSpecialties = (user?.hasSpecialties ?? false) ||
          (selectedIdsJson != null && selectedIdsJson.isNotEmpty && selectedIdsJson != '[]');
      final bool cachedHasStudyPlan = prefs.getBool('cached_has_study_plan') ?? false;
      final bool hasStudyPlan = (user?.hasStudyPlan ?? false) || cachedHasStudyPlan;

      if (user?.role == 'admin') {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminScaffold()),
        );
      } else if (!hasSelectedSpecialties) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const SpecialtySelectionScreen()),
        );
      } else if (!hasStudyPlan) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const StudyGoalScreen()),
        );
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const MainContainerScreen()),
        );
      }
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: MediaQuery.of(context).size.width > 600 ? 260 : 180,
                  height: MediaQuery.of(context).size.width > 600 ? 260 : 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 600 ? 60 : 40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width > 600 ? 60 : 40),
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SDLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n?.splashSubtitle ??
                        'منصتك الأولى لاجتياز اختبار رخصة طب الأسنان السعودي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
