import '../../data/models/user_model.dart';

abstract class AuthRepository {
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
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String fullName);
}
