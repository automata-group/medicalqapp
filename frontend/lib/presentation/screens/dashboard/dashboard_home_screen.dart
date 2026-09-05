import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/weekly_progress_card.dart';
import '../../widgets/dashboard/question_bank_card.dart';
import '../../widgets/dashboard/specialties_carousel.dart';
import '../../widgets/dashboard/exam_recall_card.dart';

import '../../providers/dashboard_provider.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchUnreadCount();
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final dashboardProvider = context.read<DashboardProvider>();
            final notificationProvider = context.read<NotificationProvider>();
            
            await dashboardProvider.loadDashboardData();
            await notificationProvider.fetchUnreadCount();
          },
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const WeeklyProgressCard(),
                const QuestionBankCard(),
                const ExamRecallCard(),
                const SpecialtiesCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
