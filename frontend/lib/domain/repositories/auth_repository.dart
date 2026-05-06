import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<void> logout();
  Future<UserModel> getProfile();
}
