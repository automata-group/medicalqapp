import '../../domain/repositories/mock_exam_repository.dart';
import '../../data/datasources/mock_exam_remote_data_source.dart';
import '../models/mock_exam_model.dart';
import '../models/question_model.dart';

class MockExamRepositoryImpl implements MockExamRepository {
  final MockExamRemoteDataSource remoteDataSource;

  MockExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MockExamModel>> getMockExams() async {
    return await remoteDataSource.getMockExams();
  }

  @override
  Future<MockExamModel> getMockExamById(String id) async {
    return await remoteDataSource.getMockExamById(id);
  }

  @override
  Future<Map<String, dynamic>> startMockExam(String mockExamId) async {
    return await remoteDataSource.startMockExam(mockExamId);
  }

  @override
  Future<List<QuestionModel>> getSectionQuestions(
      String attemptId, String sectionId) async {
    return await remoteDataSource.getSectionQuestions(attemptId, sectionId);
  }

  @override
  Future<Map<String, dynamic>?> submitAnswer(String attemptId, String questionId,
      String optionId, int timeSpent) async {
    return await remoteDataSource.submitAnswer(
        attemptId, questionId, optionId, timeSpent);
  }

  @override
  Future<Map<String, dynamic>> completeMockExam(String attemptId) async {
    return await remoteDataSource.completeMockExam(attemptId);
  }

  @override
  Future<List<dynamic>> getHistory() async {
    return await remoteDataSource.getHistory();
  }
}
