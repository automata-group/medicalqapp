import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/performance_stat_model.dart';
import '../../data/models/achievement_model.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repository;
  final SharedPreferences prefs;

  DashboardProvider({required this.repository, required this.prefs}) {
    _loadFromCache();
  }

  DashboardOverviewModel? _overview;
  List<RecentActivityModel> _recentActivities = [];
  List<PerformanceStatModel> _weeklyStats = [];
  List<PerformanceStatModel> _monthlyStats = [];
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  bool _isStatsLoading = false;
  bool _isAchievementsLoading = false;
  String? _error;

  DashboardOverviewModel? get overview => _overview;
  List<RecentActivityModel> get recentActivities => _recentActivities;
  List<PerformanceStatModel> get weeklyStats => _weeklyStats;
  List<PerformanceStatModel> get monthlyStats => _monthlyStats;
  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;
  bool get isStatsLoading => _isStatsLoading;
  bool get isAchievementsLoading => _isAchievementsLoading;
  String? get error => _error;

  void _loadFromCache() {
    try {
      final overviewJson = prefs.getString('cached_dashboard_overview');
      final activityJson = prefs.getString('cached_recent_activities');

      if (overviewJson != null) {
        _overview = DashboardOverviewModel.fromJson(json.decode(overviewJson));
        debugPrint('Dashboard Cache: Overview loaded successfully');
      }
      if (activityJson != null) {
        final List<dynamic> decoded = json.decode(activityJson);
        _recentActivities = decoded.map((e) => RecentActivityModel.fromJson(e)).toList();
        debugPrint('Dashboard Cache: ${_recentActivities.length} recent activities loaded');
      }
      
      if (_overview != null || _recentActivities.isNotEmpty) {
        // Use microtask to avoid "setState during build" in constructor
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Error loading dashboard cache: $e');
    }
  }

  void _saveToCache() {
    try {
      if (_overview != null) {
        prefs.setString('cached_dashboard_overview', json.encode(_overview!.toJson()));
      }
      if (_recentActivities.isNotEmpty) {
        prefs.setString('cached_recent_activities', 
            json.encode(_recentActivities.map((e) => e.toJson()).toList()));
      }
      debugPrint('Dashboard Cache: Saved to local storage');
    } catch (e) {
      debugPrint('Error saving dashboard cache: $e');
    }
  }

  Future<void> loadDashboardData() async {
    final hasNoData = _overview == null && _recentActivities.isEmpty;
    if (hasNoData) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    bool overviewSuccess = false;
    bool activitySuccess = false;

    try {
      await Future.wait([
        () async {
          try {
            final data = await repository.getOverview();
            // Data Validation: Only update if we got a valid response
            if (data.totalSolved >= 0) {
              _overview = data;
              overviewSuccess = true;
            }
          } catch (e) {
            debugPrint('Dashboard Overview Fetch Error: $e');
            // We keep the old _overview from cache here
          }
        }(),
        () async {
          try {
            final data = await repository.getRecentActivity();
            _recentActivities = data;
            activitySuccess = true;
          } catch (e) {
            debugPrint('Recent Activities Fetch Error: $e');
            // We keep the old _recentActivities from cache here
          }
        }(),
      ]);

      // SAFETY: Only save to cache if we actually got a successful response
      // from the network. This prevents overwriting good cache with error states.
      if (overviewSuccess || activitySuccess) {
        _saveToCache();
      }
    } catch (e) {
      if (hasNoData) {
        _error = 'Connection failed. Showing cached data.';
      }
      debugPrint('General Dashboard Load Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Triggers a refresh without showing a loading spinner if data already exists.
  /// Useful for cross-provider updates (e.g., after an exam or sync).
  void refreshStatsSilently() {
    loadDashboardData();
  }

  Future<void> loadWeeklyStats() async {
    _isStatsLoading = true;
    notifyListeners();
    try {
      final data = await repository.getWeeklyStats();
      if (data.isNotEmpty) {
        _weeklyStats = data;
      }
    } catch (e) {
      debugPrint('Weekly Stats Load Error: $e');
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyStats() async {
    _isStatsLoading = true;
    notifyListeners();
    try {
      final data = await repository.getMonthlyStats();
      if (data.isNotEmpty) {
        _monthlyStats = data;
      }
    } catch (e) {
      debugPrint('Monthly Stats Load Error: $e');
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAchievements() async {
    _isAchievementsLoading = true;
    notifyListeners();
    try {
      _achievements = await repository.getAchievements();
    } catch (e) {
      debugPrint('Achievements Load Error: $e');
    } finally {
      _isAchievementsLoading = false;
      notifyListeners();
    }
  }
}
