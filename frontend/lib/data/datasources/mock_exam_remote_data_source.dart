import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/mock_exam_model.dart';
import '../models/question_model.dart';

abstract class MockExamRemoteDataSource {
  Future<List<MockExamModel>> getMockExams();
  Future<MockExamModel> getMockExamById(String id);
  Future<Map<String, dynamic>> startMockExam(String mockExamId);
  Future<List<QuestionModel>> getSectionQuestions(
      String attemptId, String sectionId);
  Future<Map<String, dynamic>?> submitAnswer(
      String attemptId, String questionId, String optionId, int timeSpent);
  Future<Map<String, dynamic>> completeMockExam(String attemptId);
  Future<List<dynamic>> getHistory();
}

class MockExamRemoteDataSourceImpl implements MockExamRemoteDataSource {
  final DioClient dioClient;

  MockExamRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MockExamModel>> getMockExams() async {
    try {
      final res = await dioClient.dio.get('/mock-exams');
      // If this 404s, I'll need to fix backend.
      if (res.statusCode == 200 && res.data['success'] == true) {
        return (res.data['data'] as List)
            .map((e) => MockExamModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // Fallback or rethrow
      throw Exception(e.response?.data['message'] ?? 'Failed to load exams');
    }
  }

  @override
  Future<MockExamModel> getMockExamById(String id) async {
    try {
      final response = await dioClient.dio.get('/mock-exams/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return MockExamModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load exam');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load exam');
    }
  }

  @override
  Future<Map<String, dynamic>> startMockExam(String mockExamId) async {
    try {
      final response = await dioClient.dio
          .post('/mock-exams/start', data: {'mockExamId': mockExamId});
      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Failed to start exam');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to start exam');
    }
  }

  @override
  Future<List<QuestionModel>> getSectionQuestions(
      String attemptId, String sectionId) async {
    try {
      final response =
          await dioClient.dio.get('/mock-exams/$attemptId/sections/$sectionId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => QuestionModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load questions');
    }
  }

  @override
  Future<Map<String, dynamic>?> submitAnswer(String attemptId, String questionId,
      String optionId, int timeSpent) async {
    try {
      final response =
          await dioClient.dio.post('/mock-exams/$attemptId/answer', data: {
        'questionId': questionId,
        'selectedOptionId': optionId,
        'timeSpentSeconds': timeSpent
      });
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit answer');
    }
  }

  @override
  Future<Map<String, dynamic>> completeMockExam(String attemptId) async {
    try {
      final response =
          await dioClient.dio.post('/mock-exams/$attemptId/complete');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Failed to complete exam');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to complete exam');
    }
  }

  @override
  Future<List<dynamic>> getHistory() async {
    try {
      final response = await dioClient.dio.get('/mock-exams/history');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load history');
    }
  }
}
