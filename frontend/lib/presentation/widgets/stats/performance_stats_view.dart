import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import 'performance_chart_widget.dart';
import '../../../core/theme/app_colors.dart';
import 'streaks_calendar_widget.dart';
import 'radial_accuracy_gauge.dart';
import 'subject_performance_chart.dart';

class PerformanceStatsView extends StatefulWidget {
  const PerformanceStatsView({super.key});

  @override
  State<PerformanceStatsView> createState() => _PerformanceStatsViewState();
}

class _PerformanceStatsViewState extends State<PerformanceStatsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load stats on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadWeeklyStats();
      context.read<DashboardProvider>().loadMonthlyStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: l10n.weekly),
                Tab(text: l10n.monthly),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isStatsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildStatsContent(provider.weeklyStats, false, l10n),
                  _buildStatsContent(provider.monthlyStats, true, l10n),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContent(
      List<dynamic> stats, bool isMonthly, AppLocalizations l10n) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final overview = provider.overview;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accuracy Gauge Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RadialAccuracyGauge(
                        accuracy: (overview?.accuracy ?? 0).toDouble(),
                        size: 130,
                        progressColor: AppColors.primary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMiniStat(
                            label: l10n.total,
                            value: '${overview?.totalSolved ?? 0}',
                            icon: Icons.assignment_rounded,
                            color: const Color(0xFF6366F1),
                          ),
                          const SizedBox(height: 16),
                          _buildMiniStat(
                            label: l10n.studyStreak,
                            value: '${overview?.currentStreak ?? 0}',
                            icon: Icons.local_fire_department_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Theme Header: Performance Trend
              _buildSectionHeader(
                  l10n.performanceTrend, Icons.insights_rounded),

              // Main Chart Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (stats.isEmpty)
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              l10n.noResultData,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        )
                      else
                        PerformanceChartWidget(
                            stats: stats.cast(), isMonthly: isMonthly),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subject Performance Bar Chart
              _buildSectionHeader(
                  'Performance by Category', Icons.bar_chart_rounded),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SubjectPerformanceChart(
                    stats: overview?.specialtyStats ?? [],
                  ),
                ),
              ),

              if (isMonthly) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                    l10n.studyStreak, Icons.event_available_rounded),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreaksCalendarWidget(
                    monthlyStats: stats.cast(),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
