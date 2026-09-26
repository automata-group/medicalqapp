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

  @override
  Future<List<Specialty>> getSpecialties() async {
    try {
      final specialties = await remoteDataSource.getSpecialties();
      try {
        await localDataSource.saveSpecialtieslocally(specialties);
      } catch (_) {}
      return specialties;
    } catch (_) {
      try {
        final local = await localDataSource.getLocalSpecialties();
        if (local.isNotEmpty) return local;
      } catch (_) {}
      return [];
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
