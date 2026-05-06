import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dioClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        final userData = data['data'];
        final accessToken = userData['accessToken'];
        if (accessToken != null) {
          await sharedPreferences.setString('accessToken', accessToken);
        }
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.post('/auth/register', data: data);

      final responseData = response.data;
      if (responseData != null &&
          responseData['success'] == true &&
          responseData['data'] != null) {
        final userData = responseData['data'];
        final accessToken = userData['accessToken'];
        if (accessToken != null) {
          await sharedPreferences.setString('accessToken', accessToken);
        }
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to send reset email');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await dioClient.dio
          .put('/auth/reset-password/$token', data: {'password': newPassword});
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to reset password');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dioClient.dio.get('/auth/me');
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }
}
