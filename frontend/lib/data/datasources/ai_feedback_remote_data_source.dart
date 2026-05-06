import 'package:dio/dio.dart';
import '../models/ai_feedback_model.dart';

class AIFeedbackRemoteDataSource {
  final Dio dio;

  AIFeedbackRemoteDataSource({required this.dio});

  Future<AIFeedbackModel?> getLatestFeedback() async {
    try {
      final response = await dio.get('/ai-feedback/latest');
      if (response.data['data'] == null) return null;
      return AIFeedbackModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch feedback');
    }
  }

  Future<AIFeedbackModel> generateFeedback() async {
    try {
      final response = await dio.post('/ai-feedback/generate', data: {});
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to generate feedback');
      }
      return AIFeedbackModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to generate feedback');
    }
  }
}
