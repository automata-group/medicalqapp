import '../../data/models/question_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/session_model.dart';

abstract class QuestionRepository {
  Future<QuestionModel?> getNextQuestion({
    String? specialtyId,
    String? subTopic,
    String? filter,
    String? exclude,
    int? questionId,
    bool forceOffline = false,
    bool shuffle = true,
  });
  Future<AnswerResponseModel> submitAnswer(int questionId, int optionId,
      {String? confidenceLevel, int? timeTaken, String? sessionType, String? specialtyId});
  Future<SpecialtyTopicsResponse> getSpecialtyTopics(int specialtyId);
  Future<bool> toggleBookmark(int questionId);
  Future<void> reportQuestion(
      int questionId, String reason, String description);
  Future<List<QuestionModel>> getBookmarks();
  Future<void> saveSession({
    String? specialtyId,
    String? subTopic,
    String? filter,
    required List<int> attemptedIds,
    int? lastQuestionId,
    String? sessionType,
  });
  Future<SessionModel?> getActiveSession({String? specialtyId, String? subTopic, String? sessionType});
  Future<void> clearSession();
}
