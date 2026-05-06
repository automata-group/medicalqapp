import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/dashboard_home_screen.dart';
import 'stats/stats_screen.dart';

import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/providers/dashboard_provider.dart';
import '../../presentation/providers/study_goal_provider.dart';
import '../../presentation/providers/specialty_provider.dart';
import '../../presentation/providers/mock_exam_provider.dart';
import '../../presentation/providers/sync_provider.dart';
import '../../presentation/screens/library/library_screen.dart';
import 'exam/exam_start_screen.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dashboard = context.read<DashboardProvider>();

        // Set up cross-provider listeners
        context.read<SyncProvider>().onSyncComplete = () {
          dashboard.refreshStatsSilently();
        };

        dashboard.loadDashboardData();
        context.read<SyncProvider>().refreshPendingCount();
        // Also refresh specialties in case user changed them
        context.read<SpecialtyProvider>().loadUserSpecialties();
        // Ensure ALL specialties are loaded for Library/Grid
        context.read<SpecialtyProvider>().loadSpecialties();

        context.read<StudyGoalProvider>().loadGoal();
        // Pre-load mock exams for the FAB
        context.read<MockExamProvider>().loadMockExams();
      }
    });
  }

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const LibraryScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExamStartScreen(),
              ),
            );
          },
          heroTag: 'main_exam_fab',
          backgroundColor: AppColors.primary,
          elevation: 0,
          child: const Icon(Icons.timer, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 3) {
              context.read<SyncProvider>().refreshPendingCount();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 10,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: l10n.library,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: l10n.stats,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
