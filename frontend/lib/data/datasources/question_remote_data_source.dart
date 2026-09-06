import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/session_model.dart';

abstract class QuestionRemoteDataSource {
  Future<QuestionModel?> getNextQuestion(
      {String? specialtyId,
      String? subTopic,
      String? filter,
      String? exclude,
      int? questionId,
      bool shuffle = true});
  Future<AnswerResponseModel> submitAnswer(int questionId, int optionId,
      {String? confidenceLevel, int? timeTaken});
  Future<SpecialtyTopicsResponse> getSpecialtyTopics(int specialtyId);
  Future<bool> toggleBookmark(int questionId);
  Future<void> reportQuestion(
      int questionId, String reason, String description);
  Future<List<QuestionModel>> getBookmarks();
  Future<void> saveSession({
    String? specialtyId,
    String? subTopic,
    String? filter,
    required List<int> attemptedIds,
    int? lastQuestionId,
    String? sessionType,
  });
  Future<SessionModel?> getActiveSession({String? specialtyId, String? subTopic, String? sessionType});
  Future<void> clearSession();
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final DioClient dioClient;

  QuestionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<QuestionModel?> getNextQuestion(
      {String? specialtyId,
      String? subTopic,
      String? filter,
      String? exclude,
      int? questionId,
      bool shuffle = true}) async {
    try {
      final queryParams = <String, dynamic>{'mode': 'all', 'shuffle': shuffle.toString()};
      if (specialtyId != null) {
        queryParams['specialtyId'] = specialtyId;
      }
      if (subTopic != null) {
        queryParams['subTopic'] = subTopic;
      }
      if (filter != null) {
        queryParams['filter'] = filter;
      }
      if (exclude != null && exclude.isNotEmpty) {
        queryParams['exclude'] = exclude;
      }
      if (questionId != null) {
        queryParams['id'] = questionId.toString();
      }

      final response = await dioClient.get(
        '/questions/practice/next',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return QuestionModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['code'] == 'QUOTA_EXCEEDED') {
        throw Exception('QUOTA_EXCEEDED');
      }
      // If 404 or data null, it might mean no more questions
      if (e.response?.statusCode == 404 ||
          (e.response?.data?['data'] == null)) {
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint('Error parsing question: $e');
      rethrow;
    }
  }

  @override
  Future<SpecialtyTopicsResponse> getSpecialtyTopics(int specialtyId) async {
    final response =
        await dioClient.get('/questions/specialties/$specialtyId/topics');

    if (response.data['success'] == true) {
      return SpecialtyTopicsResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load topics');
    }
  }

  @override
  Future<AnswerResponseModel> submitAnswer(int questionId, int optionId,
      {String? confidenceLevel, int? timeTaken}) async {
    final Map<String, dynamic> data = {'selectedOptionId': optionId};
    if (confidenceLevel != null) {
      data['confidenceLevel'] = confidenceLevel;
    }
    if (timeTaken != null) {
      data['timeTaken'] = timeTaken;
    }

    try {
      final response = await dioClient.post(
        '/questions/$questionId/answer',
        data: data,
      );

      if (response.data['success'] == true) {
        return AnswerResponseModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to submit answer');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['code'] == 'QUOTA_EXCEEDED') {
        throw Exception('QUOTA_EXCEEDED');
      }
      rethrow;
    }
  }

  @override
  Future<bool> toggleBookmark(int questionId) async {
    final response =
        await dioClient.post('/questions/$questionId/bookmark', data: {});
    if (response.data['success'] == true) {
      return response.data['bookmarked'] == true;
    } else {
      throw Exception('Failed to toggle bookmark');
    }
  }

  @override
  Future<void> reportQuestion(
      int questionId, String reason, String description) async {
    try {
      final response = await dioClient.post(
        '/questions/$questionId/report',
        data: {
          'reason': reason,
          'description': description,
        },
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to submit report');
      }
    } on DioException catch (e) {
      final serverMsg = (e.response?.data is Map)
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(serverMsg ?? 'Failed to submit report. Please check your connection.');
    }
  }

  @override
  Future<List<QuestionModel>> getBookmarks() async {
    final response = await dioClient.get('/bookmarks');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      // Extract the 'question' object from each bookmark record and force isBookmarked to true
      return data.map((e) {
        final qJson = e['question'] as Map<String, dynamic>;
        qJson['isBookmarked'] = true; // explicitly set it
        return QuestionModel.fromJson(qJson);
      }).toList();
    } else {
      throw Exception('Failed to load bookmarks');
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
    await dioClient.post('/sessions/save', data: {
      'specialtyId': specialtyId,
      'subTopic': subTopic,
      'filter': filter,
      'attemptedIds': attemptedIds,
      'lastQuestionId': lastQuestionId,
      'sessionType': sessionType,
    });
  }

  @override
  Future<SessionModel?> getActiveSession({String? specialtyId, String? subTopic, String? sessionType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (specialtyId != null) queryParams['specialtyId'] = specialtyId;
      if (subTopic != null) queryParams['subTopic'] = subTopic;
      if (sessionType != null) queryParams['sessionType'] = sessionType;

      final response = await dioClient.get('/sessions/active', queryParameters: queryParams);
      if (response.data['success'] == true) {
        return SessionModel.fromJson(response.data['data']);
      }
    } catch (e) {
      if (e is! DioException || e.response?.statusCode != 404) {
        debugPrint('Active session fetch error: $e');
      }
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    await dioClient.delete('/sessions/clear');
  }
}
