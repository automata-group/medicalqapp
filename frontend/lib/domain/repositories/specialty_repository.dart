import '../entities/specialty.dart';

abstract class SpecialtyRepository {
  Future<List<Specialty>> getSpecialties();
  Future<void> saveUserInterests(List<int> specialtyIds);
  Future<void> saveStudyPlan(DateTime date, double hours);
  Future<List<int>> getUserSpecialties();
  Future<Map<String, dynamic>?> getStudySettings();
}
