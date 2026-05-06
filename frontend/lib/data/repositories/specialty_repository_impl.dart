import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/specialty.dart';
import '../../domain/repositories/specialty_repository.dart';
import '../datasources/specialty_remote_data_source.dart';
import '../datasources/question_local_data_source.dart';

class SpecialtyRepositoryImpl implements SpecialtyRepository {
  final SpecialtyRemoteDataSource remoteDataSource;
  final QuestionLocalDataSource localDataSource;

  SpecialtyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<List<Specialty>> getSpecialties() async {
    if (await _isOnline()) {
      try {
        final specialties = await remoteDataSource.getSpecialties();
        await localDataSource.saveSpecialtieslocally(specialties);
        return specialties;
      } catch (e) {
        // Fallback to local if remote fails even if online
        return await localDataSource.getLocalSpecialties();
      }
    } else {
      return await localDataSource.getLocalSpecialties();
    }
  }

  @override
  Future<void> saveUserInterests(List<int> specialtyIds) async {
    return await remoteDataSource.saveUserInterests(specialtyIds);
  }

  @override
  Future<void> saveStudyPlan(DateTime date, double hours) async {
    return await remoteDataSource.saveStudyPlan(date, hours);
  }

  @override
  Future<List<int>> getUserSpecialties() async {
    return await remoteDataSource.getUserSpecialties();
  }

  @override
  Future<Map<String, dynamic>?> getStudySettings() async {
    return await remoteDataSource.getStudySettings();
  }
}
