import 'package:flutter/foundation.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/datasources/question_local_data_source.dart';
import '../models/dashboard_model.dart';
import '../models/performance_stat_model.dart';
import '../models/achievement_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final QuestionLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<DashboardOverviewModel> getOverview() async {
    // 1. Get raw data from server (or its own internal cache handled by remoteDS)
    final remoteOverview = await remoteDataSource.getOverview();

    try {
      // 2. Get unsynced local data
      final localAttempts = await localDataSource.getUnsyncedAttempts();
      if (localAttempts.isEmpty) return remoteOverview;

      // 3. Merge stats
      int localCorrect = 0;
      for (var a in localAttempts) {
        if (a['isCorrect'] == 1) localCorrect++;
      }

      // Create a "Hybrid" model that adds local progress to remote stats
      return DashboardOverviewModel(
        totalSolved: remoteOverview.totalSolved + localAttempts.length,
        totalAvailableQuestions: remoteOverview.totalAvailableQuestions,
        accuracy: remoteOverview.totalSolved + localAttempts.length > 0
            ? (((remoteOverview.totalSolved * (remoteOverview.accuracy / 100)) +
                        localCorrect) /
                    (remoteOverview.totalSolved + localAttempts.length) *
                    100)
                .toInt()
            : remoteOverview.accuracy,
        currentStreak: remoteOverview.currentStreak, // Simplified: actual streak logic is on backend
        daysToExam: remoteOverview.daysToExam,
        weakAreas: remoteOverview.weakAreas,
        strongAreas: remoteOverview.strongAreas,
        activityGraph: remoteOverview.activityGraph,
        specialtyStats: remoteOverview.specialtyStats,
        allSpecialties: remoteOverview.allSpecialties,
        continueRevision: remoteOverview.continueRevision,
        motivationalQuote: remoteOverview.motivationalQuote,
      );
    } catch (_) {
      return remoteOverview;
    }
  }

  @override
  Future<List<RecentActivityModel>> getRecentActivity() async {
    final remoteActivity = await remoteDataSource.getRecentActivity();

    try {
      // Use the new "Rich" fetch that joins with local_questions
      final localRichAttempts = await localDataSource.getRichUnsyncedAttempts();
      if (localRichAttempts.isEmpty) return remoteActivity;

      // Map local rich attempts to RecentActivityModel
      final localAsModels = localRichAttempts.map((a) {
        return RecentActivityModel(
          id: a['id'] as int,
          questionText: (a['questionText'] as String? ?? 'Offline Question').split('\n').first,
          difficulty: a['difficulty'] as String? ?? 'unknown',
          isCorrect: a['isCorrect'] == 1,
          specialtyName: a['specialtyName'] as String? ?? 'Offline Practice',
          specialtyIcon: a['specialtyIcon'] as String?,
          createdAt: DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      // Merge and sort by date desc
      final merged = [...localAsModels, ...remoteActivity];
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    } catch (e) {
      debugPrint('Hybrid Activity Error: $e');
      return remoteActivity;
    }
  }

  @override
  Future<List<PerformanceStatModel>> getWeeklyStats() async {
    return await remoteDataSource.getWeeklyStats();
  }

  @override
  Future<List<PerformanceStatModel>> getMonthlyStats() async {
    return await remoteDataSource.getMonthlyStats();
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    return await remoteDataSource.getAchievements();
  }
}
