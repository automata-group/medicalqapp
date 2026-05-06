import 'package:flutter/material.dart';
import '../../domain/repositories/specialty_repository.dart';

class StudyGoalProvider extends ChangeNotifier {
  final SpecialtyRepository specialtyRepository;

  StudyGoalProvider({required this.specialtyRepository});

  Future<void> loadGoal() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await specialtyRepository.getStudySettings();
      if (data != null) {
        if (data['examDate'] != null) {
          _selectedDate = DateTime.parse(data['examDate']);
        }
        if (data['dailyStudyHours'] != null) {
          _dailyHours = (data['dailyStudyHours'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error loading study goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime? _selectedDate;
  double _dailyHours = 2.0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? get selectedDate => _selectedDate;
  double get dailyHours => _dailyHours;
  bool get isValid => _selectedDate != null;

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
      return true;
    } catch (e) {
      debugPrint('Error saving study plan: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
