import 'package:flutter/foundation.dart';
import '../../domain/repositories/question_repository.dart';
import '../../data/models/question_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/session_model.dart';

enum QuestionStatus { initial, loading, loaded, error, noQuestions }

enum AnswerStatus { initial, submitting, submitted, error }

class QuestionProvider with ChangeNotifier {
  final QuestionRepository repository;

  QuestionProvider({required this.repository});

  QuestionStatus _status = QuestionStatus.initial;
  QuestionStatus get status => _status;

  QuestionModel? _currentQuestion;
  QuestionModel? get currentQuestion => _currentQuestion;
  bool get isBookmarked => _currentQuestion?.isBookmarked ?? false;

  QuestionModel? _prefetchedQuestion;
  bool _isPrefetching = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Answer State
  AnswerStatus _answerStatus = AnswerStatus.initial;
  AnswerStatus get answerStatus => _answerStatus;

  int? _selectedOptionId;
  int? get selectedOptionId => _selectedOptionId;

  AnswerResponseModel? _answerResult;
  AnswerResponseModel? get answerResult => _answerResult;

  final Stopwatch _stopwatch = Stopwatch();
  int get lastTimeTaken => _stopwatch.elapsed.inSeconds;

  // Topics State
  List<TopicModel> _topics = [];
  List<TopicModel> get topics => _topics;
  bool _isLoadingTopics = false;
  bool get isLoadingTopics => _isLoadingTopics;

  bool _quotaExceeded = false;
  bool get quotaExceeded => _quotaExceeded;

  int _totalAttempted = 0;
  int get totalAttempted => _totalAttempted;

  int _totalInCategory = 0;
  int get totalInCategory => _totalInCategory;

  // Tracking for current session to avoid repeats
  final List<int> _sessionAttemptedIds = [];
  final List<QuestionModel> _failedSessionQuestions = []; // Track mistakes
  bool _isRetryMode = false;
  int _sessionCorrectCount = 0;
  int _currentQuestionAttempts = 0; // NEW: Track tries per question (max 3)

  int get sessionCorrectCount => _sessionCorrectCount;
  int get sessionTotalCount => _sessionAttemptedIds.length;
  bool get hasMistakes => _failedSessionQuestions.isNotEmpty;
  bool get isRetryMode => _isRetryMode;
  int get currentQuestionAttempts => _currentQuestionAttempts; // Expose

  SessionModel? _activeSessionToResume;
  SessionModel? get activeSessionToResume => _activeSessionToResume;

  String? _lastSpecialtyId;
  String? _lastSubTopic;
  String? _lastFilter;
  String? _currentSessionType;

  void resetSession() {
    _sessionAttemptedIds.clear();
    _failedSessionQuestions.clear();
    _isRetryMode = false;
    _sessionCorrectCount = 0;
    _currentQuestionAttempts = 0;
    _totalAttempted = 0;
    _answerStatus = AnswerStatus.initial;
    _selectedOptionId = null;
    _answerResult = null;
    _errorMessage = null;
    _currentQuestion = null;
    _prefetchedQuestion = null;
    _isPrefetching = false;
    _currentSessionType = null;
    _lastSpecialtyId = null;
    _lastSubTopic = null;
    _lastFilter = null;
    _activeSessionToResume = null;
    notifyListeners();
  }

  void clearCurrentQuestion() {
    _currentQuestion = null;
    _answerResult = null;
    _selectedOptionId = null;
    notifyListeners();
  }

  void startRetryMode() {
    if (_failedSessionQuestions.isEmpty) return;
    _isRetryMode = true;
    _status = QuestionStatus.initial;
    loadNextQuestion(); // Will trigger retry logic
  }

  Future<void> loadSpecialtyTopics(int specialtyId) async {
    _isLoadingTopics = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await repository.getSpecialtyTopics(specialtyId);
      _topics = response.topics;
      _quotaExceeded = response.quotaExceeded;
      _totalAttempted = response.totalAttempted;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingTopics = false;
      notifyListeners();
    }
  }

  bool _showOfflineButton = false;
  bool get showOfflineButton => _showOfflineButton;

  bool _shuffle = true;

  Future<void> loadNextQuestion({
    String? specialtyId,
    String? subTopic,
    String? filter,
    String? sessionType,
    int? questionId,
    bool forceOffline = false,
    bool shuffle = true,
  }) async {
    _shuffle = shuffle;
    _lastSpecialtyId = specialtyId;
    _lastSubTopic = subTopic;
    _lastFilter = filter;
    if (sessionType != null) _currentSessionType = sessionType;
    
    if (_currentSessionType == null) {
      if (subTopic != null) _currentSessionType = 'topic';
      else if (specialtyId != null) _currentSessionType = 'specialty';
      else _currentSessionType = 'general';
    }

    // 1. Check if we have a prefetched question ready
    if (_prefetchedQuestion != null && !forceOffline && !_isRetryMode) {
      _currentQuestion = _prefetchedQuestion;
      _prefetchedQuestion = null;
      _status = QuestionStatus.loaded;

      if (_currentQuestion != null && !_sessionAttemptedIds.contains(_currentQuestion!.id)) {
        _sessionAttemptedIds.add(_currentQuestion!.id);
      }
      
      // Reset answer state for the new question
      _answerStatus = AnswerStatus.initial;
      _selectedOptionId = null;
      _answerResult = null;
      _currentQuestionAttempts = 0;
      _stopwatch.reset();
      _stopwatch.start();
      
      notifyListeners();
      
      // Start prefetching the next one in the background
      _startPrefetch(
        specialtyId: specialtyId,
        subTopic: subTopic,
        filter: filter,
        shuffle: shuffle,
      );
      
      saveCurrentSession();
      return;
    }

    _status = QuestionStatus.loading;
    _showOfflineButton = false; // Reset
    _answerStatus = AnswerStatus.initial;
    _selectedOptionId = null;
    _answerResult = null;
    _errorMessage = null;
    _currentQuestionAttempts = 0;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();

    // Start a timer to show offline button after 10 seconds if not already loading offline
    if (!forceOffline) {
      Future.delayed(const Duration(seconds: 10), () {
        if (_status == QuestionStatus.loading && !_showOfflineButton) {
          _showOfflineButton = true;
          notifyListeners();
        }
      });
    }

    try {
      if (_isRetryMode && _failedSessionQuestions.isNotEmpty) {
        _currentQuestion = _failedSessionQuestions.removeAt(0);
        _status = QuestionStatus.loaded;
      } else if (_isRetryMode && _failedSessionQuestions.isEmpty) {
        _currentQuestion = null;
        _isRetryMode = false;
        _status = QuestionStatus.noQuestions;
      } else {
        final excludeList = _sessionAttemptedIds.where((id) => id != questionId).toList();
        final excludeString = excludeList.isNotEmpty
            ? excludeList.join(',')
            : null;

        final question = await repository.getNextQuestion(
          specialtyId: specialtyId,
          subTopic: subTopic,
          filter: filter,
          exclude: excludeString,
          questionId: questionId,
          forceOffline: forceOffline,
          shuffle: shuffle,
        );
        if (question != null) {
          // Shuffle options for better practice (only if shuffle is true)
          if (shuffle) {
            final shuffledOptions = List<OptionModel>.from(question.options)..shuffle();
            _currentQuestion = question.copyWith(options: shuffledOptions);
          } else {
            _currentQuestion = question;
          }
          
          _totalInCategory = question.totalInCategory;
          if (!_sessionAttemptedIds.contains(question.id)) {
            _sessionAttemptedIds.add(question.id);
          }
          _status = QuestionStatus.loaded;

          // After successful load, prefetch the NEXT one
          _startPrefetch(
            specialtyId: specialtyId,
            subTopic: subTopic,
            filter: filter,
            shuffle: shuffle,
          );
        } else {
          _currentQuestion = null;
          _status = QuestionStatus.noQuestions;
        }
      }
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
    saveCurrentSession();
  }

  Future<void> _startPrefetch({
    String? specialtyId,
    String? subTopic,
    String? filter,
    bool shuffle = true,
  }) async {
    if (_isPrefetching || _prefetchedQuestion != null || _isRetryMode) return;

    _isPrefetching = true;
    try {
      final excludeString = _sessionAttemptedIds.isNotEmpty
          ? _sessionAttemptedIds.join(',')
          : null;

      final question = await repository.getNextQuestion(
        specialtyId: specialtyId,
        subTopic: subTopic,
        filter: filter,
        exclude: excludeString,
        shuffle: shuffle,
      );

      if (question != null) {
        // Shuffle options during prefetch so it's ready (only if shuffle is true)
        if (shuffle) {
          final shuffledOptions = List<OptionModel>.from(question.options)..shuffle();
          _prefetchedQuestion = question.copyWith(options: shuffledOptions);
        } else {
          _prefetchedQuestion = question;
        }
      }
    } catch (e) {
      debugPrint('Prefetch failed: $e');
      // Silently fail prefetch, we'll try again on next manual load
    } finally {
      _isPrefetching = false;
    }
  }

  void selectOption(int optionId) {
    if (_answerStatus == AnswerStatus.submitted) return;
    _selectedOptionId = optionId;
    notifyListeners();
  }

  Future<void> submitAnswer({String? confidenceLevel}) async {
    if (_currentQuestion == null ||
        _selectedOptionId == null ||
        _answerStatus == AnswerStatus.submitting ||
        _answerStatus == AnswerStatus.submitted) {
      return;
    }

    _answerStatus = AnswerStatus.submitting;
    _stopwatch.stop();
    final timeTaken = _stopwatch.elapsed.inSeconds;
    notifyListeners();

    try {
      final result = await repository.submitAnswer(
        _currentQuestion!.id,
        _selectedOptionId!,
        confidenceLevel: confidenceLevel,
        timeTaken: timeTaken,
      );
      _answerResult = result;
      _answerStatus = AnswerStatus.submitted;

      if (result.isCorrect) {
        _totalAttempted++; // Only count as fully attempted if solved or failed 3 times
        if (!_isRetryMode) _sessionCorrectCount++;
      } else {
        _currentQuestionAttempts++;
        if (_currentQuestionAttempts >= 3) {
          _totalAttempted++; // Final fail
          // If wrong 3 times, add to failed list for potential retry later
          if (!_failedSessionQuestions
              .any((q) => q.id == _currentQuestion!.id)) {
            _failedSessionQuestions.add(_currentQuestion!);
          }
        }
        // If < 3 attempts, we leave it in 'submitted' state.
        // The UI will show the bottom sheet with a "Try Again" button,
        // which will call `retryCurrentQuestion()` to do the reset.
      }
    } catch (e) {
      _answerStatus = AnswerStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
    saveCurrentSession();
  }

  void retryCurrentQuestion() {
    if (_currentQuestionAttempts >= 3) return;
    _answerStatus = AnswerStatus.initial;
    _selectedOptionId = null;
    _answerResult = null;
    _stopwatch.start();
    notifyListeners();
  }

  Future<void> toggleBookmark() async {
    if (_currentQuestion == null) return;
    try {
      final newStatus = await repository.toggleBookmark(_currentQuestion!.id);
      // Update local state without full reload
      _currentQuestion = QuestionModel(
        id: _currentQuestion!.id,
        text: _currentQuestion!.text,
        difficulty: _currentQuestion!.difficulty,
        specialty: _currentQuestion!.specialty,
        options: _currentQuestion!.options,
        isBookmarked: newStatus,
        isPremium: _currentQuestion!.isPremium,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update bookmark: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> submitReport(String reason, String description) async {
    if (_currentQuestion == null) return false;
    try {
      await repository.reportQuestion(
          _currentQuestion!.id, reason, description);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit report: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Bookmarks State
  List<QuestionModel> _bookmarkedQuestions = [];
  bool _isLoadingBookmarks = false;

  List<QuestionModel> get bookmarkedQuestions => _bookmarkedQuestions;
  bool get isLoadingBookmarks => _isLoadingBookmarks;

  Future<void> fetchBookmarks() async {
    _isLoadingBookmarks = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _bookmarkedQuestions = await repository.getBookmarks();
    } catch (e) {
      _errorMessage = 'Failed to load bookmarks: ${e.toString()}';
    } finally {
      _isLoadingBookmarks = false;
      notifyListeners();
    }
  }

  // --- Session Persistence ---

  Future<void> saveCurrentSession() async {
    if (_currentQuestion == null || _isRetryMode) return;
    try {
      await repository.saveSession(
        specialtyId: _lastSpecialtyId,
        subTopic: _lastSubTopic,
        filter: _lastFilter,
        attemptedIds: _sessionAttemptedIds,
        lastQuestionId: _currentQuestion!.id,
        sessionType: _currentSessionType,
      );
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }
  }

  Future<void> checkActiveSession({String? specialtyId, String? subTopic, String? sessionType}) async {
    try {
      _activeSessionToResume = await repository.getActiveSession(
        specialtyId: specialtyId,
        subTopic: subTopic,
        sessionType: sessionType,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking active session: $e');
    }
  }

  Future<void> restoreSession(SessionModel session) async {
    _status = QuestionStatus.loading;
    notifyListeners();

    _lastSpecialtyId = session.specialtyId;
    _lastSubTopic = session.subTopic;
    _lastFilter = session.filter;
    _currentSessionType = session.sessionType;
    _sessionAttemptedIds.clear();
    _sessionAttemptedIds.addAll(session.attemptedIds);
    _activeSessionToResume = null;
    
    // Reset other session state
    _failedSessionQuestions.clear();
    _isRetryMode = false;
    _sessionCorrectCount = 0; // Ideally we'd store this too, but for now we reset

    await loadNextQuestion(
      specialtyId: _lastSpecialtyId,
      subTopic: _lastSubTopic,
      filter: _lastFilter,
      shuffle: _shuffle,
      questionId: session.lastQuestionId,
    );
  }

  void discardActiveSession() {
    _activeSessionToResume = null;
    repository.clearSession();
    notifyListeners();
  }
}
