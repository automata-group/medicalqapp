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
  Future<void> register(Map<String, dynamic> data) async {
    return await remoteDataSource.register(data);
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
