import '../../data/models/mock_exam_model.dart';
import '../../data/models/question_model.dart';

abstract class MockExamRepository {
  Future<List<MockExamModel>> getMockExams();
  Future<MockExamModel> getMockExamById(String id);
  Future<Map<String, dynamic>> startMockExam(String mockExamId);
  Future<List<QuestionModel>> getSectionQuestions(
      String attemptId, String sectionId);
  Future<Map<String, dynamic>?> submitAnswer(
      String attemptId, String questionId, String optionId, int timeSpent);
  Future<Map<String, dynamic>> completeMockExam(String attemptId);
  Future<List<dynamic>> getHistory();
}
