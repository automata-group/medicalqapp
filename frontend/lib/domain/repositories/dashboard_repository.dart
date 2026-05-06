import '../../data/models/dashboard_model.dart';
import '../../data/models/performance_stat_model.dart';
import '../../data/models/achievement_model.dart';

abstract class DashboardRepository {
  Future<DashboardOverviewModel> getOverview();
  Future<List<RecentActivityModel>> getRecentActivity();
  Future<List<PerformanceStatModel>> getWeeklyStats();
  Future<List<PerformanceStatModel>> getMonthlyStats();
  Future<List<AchievementModel>> getAchievements();
}
