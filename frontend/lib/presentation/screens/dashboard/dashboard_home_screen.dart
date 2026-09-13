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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final dashboardProvider = context.read<DashboardProvider>();
            final notificationProvider = context.read<NotificationProvider>();
            
            await dashboardProvider.loadDashboardData();
            await notificationProvider.fetchUnreadCount();
          },
          color: Theme.of(context).primaryColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 700;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: isTablet ? 20 : 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardHeader(),
                        _buildCardsSection(isTablet),
                        const SpecialtiesCarousel(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection(bool isTablet) {
    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                flex: 12,
                child: WeeklyProgressCard(
                  margin: EdgeInsets.zero,
                  isTablet: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 11,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuestionBankCard(
                      margin: EdgeInsets.zero,
                      isTablet: true,
                    ),
                    SizedBox(height: 12),
                    ExamRecallCard(
                      margin: EdgeInsets.zero,
                      isTablet: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        WeeklyProgressCard(),
        QuestionBankCard(),
        ExamRecallCard(),
      ],
    );
  }
}
