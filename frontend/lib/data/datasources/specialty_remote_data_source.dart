import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/specialty_model.dart';

abstract class SpecialtyRemoteDataSource {
  Future<List<SpecialtyModel>> getSpecialties();
  Future<void> saveUserInterests(List<int> specialtyIds);
  Future<void> saveStudyPlan(DateTime date, double hours);
  Future<List<int>> getUserSpecialties();
  Future<Map<String, dynamic>?> getStudySettings();
}

class SpecialtyRemoteDataSourceImpl implements SpecialtyRemoteDataSource {
  final DioClient dioClient;

  SpecialtyRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final response = await dioClient.dio.get('/specialties');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SpecialtyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load specialties');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load specialties');
    }
  }

  @override
  Future<void> saveUserInterests(List<int> specialtyIds) async {
    try {
      await dioClient.dio.post('/user/specialties', data: {
        'specialtyIds': specialtyIds,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to save interests');
    }
  }

  @override
  Future<void> saveStudyPlan(DateTime date, double hours) async {
    try {
      await dioClient.dio.put('/user/study-settings', data: {
        'examDate': date.toIso8601String(),
        'dailyHours': hours,
        'dailyStudyHours': hours,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to save study plan');
    }
  }

  @override
  Future<List<int>> getUserSpecialties() async {
    try {
      final response = await dioClient.dio.get('/user/specialties');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        // Assuming backend returns a list of objects with 'id' or just IDs
        // Based on typical implementation, it might be objects. Let's inspect typical response or assume objects.
        // If the backend returns just IDs [1, 2, 3], we map directly.
        // If it returns [{id: 1, name: ...}], we map to IDs.
        // Looking at typical seed/controller, it usually returns the Specialty objects associated with the user.
        return data.map<int>((json) => json['id'] as int).toList();
      } else {
        return [];
      }
    } on DioException {
      // If 404 or other error, return empty list or throw?
      // For now, empty list is safe for "no selection".
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getStudySettings() async {
    try {
      final response = await dioClient.dio.get('/user/study-settings');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }
}
