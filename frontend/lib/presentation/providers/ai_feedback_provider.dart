import 'package:flutter/material.dart';
import '../../data/datasources/ai_feedback_remote_data_source.dart';
import '../../data/models/ai_feedback_model.dart';

class AIFeedbackProvider extends ChangeNotifier {
  final AIFeedbackRemoteDataSource remoteDataSource;

  AIFeedbackProvider({required this.remoteDataSource});

  AIFeedbackModel? _latestFeedback;
  bool _isLoading = false;
  String? _error;

  AIFeedbackModel? get latestFeedback => _latestFeedback;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLatestFeedback() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestFeedback = await remoteDataSource.getLatestFeedback();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateNewFeedback() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestFeedback = await remoteDataSource.generateFeedback();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
