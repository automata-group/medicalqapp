import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    if (kIsWeb || await _isOnline()) {
      try {
        final specialties = await remoteDataSource.getSpecialties();
        if (!kIsWeb) {
          await localDataSource.saveSpecialtieslocally(specialties);
        }
        return specialties;
      } catch (e) {
        if (kIsWeb) return [];
        return await localDataSource.getLocalSpecialties();
      }
    } else {
      if (kIsWeb) return [];
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
