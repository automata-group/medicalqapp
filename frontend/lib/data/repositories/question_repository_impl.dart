import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../datasources/question_local_data_source.dart';
import '../datasources/question_remote_data_source.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/session_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource remoteDataSource;
  final QuestionLocalDataSource localDataSource;

  QuestionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  bool? _lastOnlineResult;
  DateTime? _lastCheckTime;

  Future<bool> _isOnline() async {
    if (kIsWeb) return true; // Browsers handle their own connectivity and socket checks fail on web
    final now = DateTime.now();
    if (_lastOnlineResult != null && _lastCheckTime != null) {
      if (now.difference(_lastCheckTime!) < const Duration(seconds: 30)) {
        return _lastOnlineResult!;
      }
    }

    try {
      // First check fast connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.any((r) => r == ConnectivityResult.none)) {
        _lastOnlineResult = false;
        _lastCheckTime = now;
        return false;
      }

      // Then check actual internet with 5s timeout
      final hasInternet = await InternetConnectionChecker.instance.hasConnection
          .timeout(const Duration(seconds: 5), onTimeout: () => false);

      _lastOnlineResult = hasInternet;
      _lastCheckTime = now;
      return hasInternet;
    } catch (_) {
      _lastOnlineResult = false;
      _lastCheckTime = now;
      return false;
    }
  }

  @override
  Future<QuestionModel?> getNextQuestion({
    String? specialtyId,
    String? subTopic,
    String? filter,
    String? exclude,
    int? questionId,
    bool forceOffline = false,
    bool shuffle = true,
  }) async {
    if (!forceOffline && await _isOnline()) {
      return await remoteDataSource.getNextQuestion(
          specialtyId: specialtyId,
          subTopic: subTopic,
          filter: filter,
          exclude: exclude,
          questionId: questionId,
          shuffle: shuffle);
    } else {
      return await localDataSource.getNextQuestionOffline(
          specialtyId: specialtyId, subTopic: subTopic, exclude: exclude);
    }
  }

  @override
  Future<AnswerResponseModel> submitAnswer(int questionId, int optionId,
      {String? confidenceLevel, int? timeTaken}) async {
    if (await _isOnline()) {
      return await remoteDataSource.submitAnswer(questionId, optionId,
          confidenceLevel: confidenceLevel, timeTaken: timeTaken);
    } else {
      return await localDataSource.submitAnswerOffline(
        questionId,
        optionId,
        timeTaken: timeTaken,
      );
    }
  }

  @override
  Future<SpecialtyTopicsResponse> getSpecialtyTopics(int specialtyId) async {
    if (await _isOnline()) {
      return await remoteDataSource.getSpecialtyTopics(specialtyId);
    } else {
      return await localDataSource.getSpecialtyTopicsOffline(specialtyId);
    }
  }

  @override
  Future<bool> toggleBookmark(int questionId) async {
    return await remoteDataSource.toggleBookmark(questionId);
  }

  @override
  Future<void> reportQuestion(
      int questionId, String reason, String description) async {
    return await remoteDataSource.reportQuestion(
        questionId, reason, description);
  }

  @override
  Future<List<QuestionModel>> getBookmarks() async {
    if (await _isOnline()) {
      return await remoteDataSource.getBookmarks();
    } else {
      // Offline fallback: for now just return empty, or fetch offline bookmarks
      return [];
    }
  }

  @override
  Future<void> saveSession({
    String? specialtyId,
    String? subTopic,
    String? filter,
    required List<int> attemptedIds,
    int? lastQuestionId,
    String? sessionType,
  }) async {
    await remoteDataSource.saveSession(
      specialtyId: specialtyId,
      subTopic: subTopic,
      filter: filter,
      attemptedIds: attemptedIds,
      lastQuestionId: lastQuestionId,
      sessionType: sessionType,
    );
  }

  @override
  Future<SessionModel?> getActiveSession({String? specialtyId, String? subTopic, String? sessionType}) async {
    return await remoteDataSource.getActiveSession(specialtyId: specialtyId, subTopic: subTopic, sessionType: sessionType);
  }

  @override
  Future<void> clearSession() async {
    await remoteDataSource.clearSession();
  }
}
