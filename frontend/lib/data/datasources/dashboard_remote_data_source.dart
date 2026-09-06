import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';
import '../models/performance_stat_model.dart';
import '../models/achievement_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardOverviewModel> getOverview();
  Future<List<RecentActivityModel>> getRecentActivity();
  Future<List<PerformanceStatModel>> getWeeklyStats();
  Future<List<PerformanceStatModel>> getMonthlyStats();
  Future<List<AchievementModel>> getAchievements();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DashboardOverviewModel> getOverview() async {
    try {
      final response = await dioClient.dio.get('/dashboard/overview');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DashboardOverviewModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load dashboard overview');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load dashboard overview');
    }
  }

  @override
  Future<List<RecentActivityModel>> getRecentActivity() async {
    try {
      final response = await dioClient.dio.get('/dashboard/recent-activity');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => RecentActivityModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load recent activity');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load recent activity');
    }
  }

  @override
  Future<List<PerformanceStatModel>> getWeeklyStats() async {
    try {
      final response = await dioClient.dio.get('/dashboard/stats/weekly');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => PerformanceStatModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load weekly stats');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load weekly stats');
    }
  }

  @override
  Future<List<PerformanceStatModel>> getMonthlyStats() async {
    try {
      final response = await dioClient.dio.get('/dashboard/stats/monthly');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => PerformanceStatModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load monthly stats');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load monthly stats');
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await dioClient.dio.get('/dashboard/achievements');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => AchievementModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load achievements');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load achievements');
    }
  }
}
