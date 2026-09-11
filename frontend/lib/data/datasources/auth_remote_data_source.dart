import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signInWithGoogle({
    required String idToken,
    String? email,
    String? fullName,
    String? googleId,
    String? avatar,
  });
  Future<UserModel> signInWithApple({
    required String identityToken,
    required String appleId,
    String? email,
    String? fullName,
  });
  Future<void> register(Map<String, dynamic> data);
  Future<UserModel> verifyEmail(String email, String otp);
  Future<void> resendVerificationCode(String email);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String fullName);
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
  Future<UserModel> signInWithGoogle({
    required String idToken,
    String? email,
    String? fullName,
    String? googleId,
    String? avatar,
  }) async {
    try {
      final response = await dioClient.dio.post('/auth/google', data: {
        'idToken': idToken,
        if (email != null) 'email': email,
        if (fullName != null) 'fullName': fullName,
        if (googleId != null) 'googleId': googleId,
        if (avatar != null) 'avatar': avatar,
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
      throw Exception(e.response?.data['message'] ?? 'Google sign-in failed');
    }
  }

  @override
  Future<UserModel> signInWithApple({
    required String identityToken,
    required String appleId,
    String? email,
    String? fullName,
  }) async {
    try {
      final response = await dioClient.dio.post('/auth/apple', data: {
        'identityToken': identityToken,
        'appleId': appleId,
        if (email != null) 'email': email,
        if (fullName != null) 'fullName': fullName,
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
      throw Exception(e.response?.data['message'] ?? 'Apple sign-in failed');
    }
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    try {
      await dioClient.dio.post('/auth/register', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<UserModel> verifyEmail(String email, String otp) async {
    try {
      final response = await dioClient.dio.post('/auth/verify-email', data: {
        'email': email,
        'otp': otp,
      });

      final responseData = response.data;
      if (responseData != null &&
          responseData['success'] == true &&
          responseData['data'] != null) {
        final userData = responseData['data'];
        final accessToken = userData['accessToken'];
        if (accessToken != null) {
          await sharedPreferences.setString('accessToken', accessToken);
        }
        return UserModel.fromJson(userData);
      } else {
        throw Exception(responseData?['message'] ?? 'Failed to verify email');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Verification failed');
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    try {
      await dioClient.dio.post('/auth/resend-verification', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to resend verification code');
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
  Future<void> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    try {
      await dioClient.dio.post('/auth/reset-password-otp', data: {
        'email': email,
        'otp': otp,
        'password': newPassword,
      });
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

  @override
  Future<UserModel> updateProfile(String fullName) async {
    try {
      final response = await dioClient.dio.put('/user/profile', data: {
        'fullName': fullName,
      });
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
    }
  }
}
