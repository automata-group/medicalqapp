import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class AdminRemoteDataSource {
  final DioClient dioClient;

  AdminRemoteDataSource({required this.dioClient});

  // ========== Users & Revenue ==========

  Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await dioClient.dio.get(
        '/admin/users',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load users');
    }
  }

  Future<Map<String, dynamic>> overrideUserSubscription(
      String userId, bool isPro,
      {int durationDays = 30}) async {
    try {
      final response = await dioClient.dio.put(
        '/admin/users/$userId/subscription',
        data: {
          'status': isPro ? 'active' : 'inactive',
          'durationDays': durationDays,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to override subscription');
    }
  }

  Future<Map<String, dynamic>> getRevenueStats() async {
    try {
      final response = await dioClient.dio.get('/admin/analytics/revenue');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load revenue stats');
    }
  }

  // ========== Promos & Referrals ==========

  Future<Map<String, dynamic>> getDiscountCodes() async {
    try {
      final response = await dioClient.dio.get('/admin/discounts');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load discount codes');
    }
  }

  Future<Map<String, dynamic>> createDiscountCode(
      Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.post('/admin/discounts', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to create discount code');
    }
  }

  Future<Map<String, dynamic>> toggleDiscountCode(
      String id, bool isActive) async {
    try {
      final response = await dioClient.dio
          .put('/admin/discounts/$id', data: {'isActive': isActive});
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to toggle discount code');
    }
  }

  // ========== Content Management ==========

  Future<Map<String, dynamic>> bulkImportQuestions(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await dioClient.dio.post(
        '/admin/questions/bulk-import',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to bulk import questions');
    }
  }

  // ========== Moderation ==========

  Future<Map<String, dynamic>> getReports(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await dioClient.dio.get('/admin/reports',
          queryParameters: {'page': page, 'limit': limit});
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load reports');
    }
  }

  Future<Map<String, dynamic>> updateReportStatus(
      String reportId, String status) async {
    try {
      final response = await dioClient.dio
          .put('/admin/reports/$reportId', data: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update report status');
    }
  }
}
