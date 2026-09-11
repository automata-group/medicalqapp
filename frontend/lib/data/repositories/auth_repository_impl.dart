import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserModel> signInWithGoogle({
    required String idToken,
    String? email,
    String? fullName,
    String? googleId,
    String? avatar,
  }) async {
    return await remoteDataSource.signInWithGoogle(
      idToken: idToken,
      email: email,
      fullName: fullName,
      googleId: googleId,
      avatar: avatar,
    );
  }

  @override
  Future<UserModel> signInWithApple({
    required String identityToken,
    required String appleId,
    String? email,
    String? fullName,
  }) async {
    return await remoteDataSource.signInWithApple(
      identityToken: identityToken,
      appleId: appleId,
      email: email,
      fullName: fullName,
    );
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    return await remoteDataSource.register(data);
  }

  @override
  Future<UserModel> verifyEmail(String email, String otp) async {
    return await remoteDataSource.verifyEmail(email, otp);
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    return await remoteDataSource.resendVerificationCode(email);
  }

  @override
  Future<void> logout() async {
    // Implementation is handled in AuthProvider by clearing SharedPreferences
  }

  @override
  Future<UserModel> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<UserModel> updateProfile(String fullName) async {
    return await remoteDataSource.updateProfile(fullName);
  }
}
