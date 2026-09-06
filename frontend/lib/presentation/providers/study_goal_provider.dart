import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/specialty_repository.dart';

class StudyGoalProvider extends ChangeNotifier {
  final SpecialtyRepository specialtyRepository;
  final SharedPreferences prefs;

  DateTime? _selectedDate;
  double _dailyHours = 2.0;
  bool _isLoading = false;

  StudyGoalProvider({
    required this.specialtyRepository,
    required this.prefs,
  }) {
    _loadFromCache();
  }

  bool get isLoading => _isLoading;
  DateTime? get selectedDate => _selectedDate;
  double get dailyHours => _dailyHours;
  bool get isValid => _selectedDate != null;

  void _loadFromCache() {
    try {
      final cachedDateStr = prefs.getString('cached_exam_date');
      if (cachedDateStr != null && cachedDateStr.isNotEmpty) {
        _selectedDate = DateTime.tryParse(cachedDateStr);
      }
      final cachedHours = prefs.getDouble('cached_daily_hours');
      if (cachedHours != null && cachedHours >= 1.0) {
        _dailyHours = cachedHours;
      }
    } catch (e) {
      debugPrint('Error loading study goal cache: $e');
    }
  }

  Future<void> loadGoal() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await specialtyRepository.getStudySettings();
      if (data != null) {
        if (data['examDate'] != null) {
          final parsed = DateTime.tryParse(data['examDate'].toString());
          if (parsed != null) {
            _selectedDate = parsed;
            await prefs.setString('cached_exam_date', _selectedDate!.toIso8601String());
          }
        }
        final rawHours = data['dailyHours'] ?? data['dailyStudyHours'];
        if (rawHours != null) {
          _dailyHours = (rawHours as num).toDouble();
          await prefs.setDouble('cached_daily_hours', _dailyHours);
        }
        await prefs.setBool('cached_has_study_plan', true);
      }
    } catch (e) {
      debugPrint('Error loading study goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDailyHours(double hours) {
    _dailyHours = hours;
    notifyListeners();
  }

  Future<bool> saveGoal() async {
    if (_selectedDate == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await specialtyRepository.saveStudyPlan(_selectedDate!, _dailyHours);
      await prefs.setBool('cached_has_study_plan', true);
      await prefs.setString('cached_exam_date', _selectedDate!.toIso8601String());
      await prefs.setDouble('cached_daily_hours', _dailyHours);
      return true;
    } catch (e) {
      debugPrint('Error saving study plan: $e');
      // Even if remote save had network glitch, we save locally so user is not trapped
      await prefs.setBool('cached_has_study_plan', true);
      await prefs.setString('cached_exam_date', _selectedDate!.toIso8601String());
      await prefs.setDouble('cached_daily_hours', _dailyHours);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
