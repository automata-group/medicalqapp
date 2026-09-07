import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<UserModel> verifyEmail(String email, String otp);
  Future<void> resendVerificationCode(String email);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String fullName);
}
