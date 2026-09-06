import 'package:flutter/foundation.dart';
import '../../domain/repositories/question_repository.dart';
import '../../data/models/question_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/session_model.dart';

enum QuestionStatus { initial, loading, loaded, error, noQuestions }

enum AnswerStatus { initial, submitting, submitted, error }

class ExamHistoryItem {
  final QuestionModel question;
  final int? selectedOptionId;
  final int? selectedAnswerIndex;
  final AnswerResponseModel? answerResult;
  final int timeTaken;
  final AnswerStatus answerStatus;
  final bool isAnswerChecked;

  ExamHistoryItem({
    required this.question,
    this.selectedOptionId,
    this.selectedAnswerIndex,
    this.answerResult,
    this.timeTaken = 0,
    this.answerStatus = AnswerStatus.initial,
    this.isAnswerChecked = false,
  });

  ExamHistoryItem copyWith({
    QuestionModel? question,
    int? selectedOptionId,
    int? selectedAnswerIndex,
    AnswerResponseModel? answerResult,
    int? timeTaken,
    AnswerStatus? answerStatus,
    bool? isAnswerChecked,
  }) {
    return ExamHistoryItem(
      question: question ?? this.question,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      answerResult: answerResult ?? this.answerResult,
      timeTaken: timeTaken ?? this.timeTaken,
      answerStatus: answerStatus ?? this.answerStatus,
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
    );
  }
}

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

  int? _selectedAnswerIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

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

  // Session History for Previous / Next Navigation
  final List<ExamHistoryItem> _history = [];
  int _historyIndex = -1;

  int get currentHistoryIndex => _historyIndex;
  int get historyLength => _history.length;
  bool get hasPreviousQuestion => _historyIndex > 0;
  bool get hasNextInHistory => _historyIndex < _history.length - 1;
  bool get isCurrentAnswerChecked => _answerStatus == AnswerStatus.submitted;

  // Tracking for current session to avoid repeats
  final List<int> _sessionAttemptedIds = [];
  final List<QuestionModel> _failedSessionQuestions = []; // Track mistakes
  bool _isRetryMode = false;
  int _sessionCorrectCount = 0;

  int get sessionCorrectCount => _sessionCorrectCount;
  int get sessionTotalCount => _sessionAttemptedIds.length;
  List<int> get sessionAttemptedIds => _sessionAttemptedIds;
  bool get hasMistakes => _failedSessionQuestions.isNotEmpty;
  bool get isRetryMode => _isRetryMode;

  int get currentQuestionIndex {
    if (_history.isEmpty || _historyIndex < 0) {
      return _sessionAttemptedIds.length;
    }
    final offsetFromLatest = (_history.length - 1) - _historyIndex;
    final index = _sessionAttemptedIds.length - offsetFromLatest;
    return index < 0 ? 0 : index;
  }

  SessionModel? _activeSessionToResume;
  SessionModel? get activeSessionToResume => _activeSessionToResume;

  String? _lastSpecialtyId;
  String? _lastSubTopic;
  String? _lastFilter;
  String? _currentSessionType;

  void resetSession() {
    _status = QuestionStatus.loading;
    _history.clear();
    _historyIndex = -1;
    _sessionAttemptedIds.clear();
    _failedSessionQuestions.clear();
    _isRetryMode = false;
    _sessionCorrectCount = 0;
    _totalAttempted = 0;
    _answerStatus = AnswerStatus.initial;
    _selectedOptionId = null;
    _selectedAnswerIndex = null;
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
    _status = QuestionStatus.loading;
    _errorMessage = null;
    _currentQuestion = null;
    _answerResult = null;
    _selectedOptionId = null;
    _selectedAnswerIndex = null;
    notifyListeners();
  }

  void startRetryMode() {
    if (_failedSessionQuestions.isEmpty) return;
    _isRetryMode = true;
    _status = QuestionStatus.initial;
    loadNextQuestion();
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

  void loadPreviousQuestion() {
    if (!hasPreviousQuestion) return;
    _historyIndex--;
    _restoreHistoryItem(_history[_historyIndex]);
    notifyListeners();
  }

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
    _lastSpecialtyId = specialtyId ?? _lastSpecialtyId;
    _lastSubTopic = subTopic ?? _lastSubTopic;
    _lastFilter = filter ?? _lastFilter;
    if (sessionType != null) _currentSessionType = sessionType;
    
    if (_currentSessionType == null) {
      if (subTopic != null) {
        _currentSessionType = 'topic';
      } else if (specialtyId != null) {
        _currentSessionType = 'specialty';
      } else {
        _currentSessionType = 'general';
      }
    }

    // 1. If we are navigating within already visited history, move to the next item
    if (_historyIndex < _history.length - 1 && !_isRetryMode && questionId == null) {
      _historyIndex++;
      _restoreHistoryItem(_history[_historyIndex]);
      notifyListeners();
      return;
    }

    // Mark current question as attempted
    if (_currentQuestion != null && !_isRetryMode) {
      if (!_sessionAttemptedIds.contains(_currentQuestion!.id)) {
        _sessionAttemptedIds.add(_currentQuestion!.id);
      }
    }

    // 2. Check if we have a prefetched question ready
    if (_prefetchedQuestion != null && !forceOffline && !_isRetryMode && questionId == null) {
      _currentQuestion = _prefetchedQuestion;
      _prefetchedQuestion = null;
      _status = QuestionStatus.loaded;
      
      _answerStatus = AnswerStatus.initial;
      _selectedOptionId = null;
      _selectedAnswerIndex = null;
      _answerResult = null;
      _stopwatch.reset();
      _stopwatch.start();
      
      _history.add(ExamHistoryItem(
        question: _currentQuestion!,
        answerStatus: AnswerStatus.initial,
        isAnswerChecked: false,
      ));
      _historyIndex = _history.length - 1;
      
      notifyListeners();
      
      _startPrefetch(
        specialtyId: _lastSpecialtyId,
        subTopic: _lastSubTopic,
        filter: _lastFilter,
        shuffle: shuffle,
      );
      
      saveCurrentSession();
      return;
    }

    _status = QuestionStatus.loading;
    _showOfflineButton = false;
    _answerStatus = AnswerStatus.initial;
    _selectedOptionId = null;
    _selectedAnswerIndex = null;
    _answerResult = null;
    _errorMessage = null;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();

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
        _history.add(ExamHistoryItem(
          question: _currentQuestion!,
          answerStatus: AnswerStatus.initial,
          isAnswerChecked: false,
        ));
        _historyIndex = _history.length - 1;
      } else if (_isRetryMode && _failedSessionQuestions.isEmpty) {
        _currentQuestion = null;
        _isRetryMode = false;
        _status = QuestionStatus.noQuestions;
      } else {
        final currentExcludes = <int>{..._sessionAttemptedIds};
        if (_currentQuestion != null) currentExcludes.add(_currentQuestion!.id);
        if (questionId != null) currentExcludes.remove(questionId);

        final excludeString = currentExcludes.isNotEmpty
            ? currentExcludes.join(',')
            : null;

        final question = await repository.getNextQuestion(
          specialtyId: _lastSpecialtyId,
          subTopic: _lastSubTopic,
          filter: _lastFilter,
          exclude: excludeString,
          questionId: questionId,
          forceOffline: forceOffline,
          shuffle: shuffle,
        );
        if (question != null) {
          if (shuffle) {
            final shuffledOptions = List<OptionModel>.from(question.options)..shuffle();
            _currentQuestion = question.copyWith(options: shuffledOptions);
          } else {
            _currentQuestion = question;
          }
          
          _totalInCategory = question.totalInCategory;
          _status = QuestionStatus.loaded;

          _history.add(ExamHistoryItem(
            question: _currentQuestion!,
            answerStatus: AnswerStatus.initial,
            isAnswerChecked: false,
          ));
          _historyIndex = _history.length - 1;

          _startPrefetch(
            specialtyId: _lastSpecialtyId,
            subTopic: _lastSubTopic,
            filter: _lastFilter,
            shuffle: shuffle,
          );
        } else {
          _currentQuestion = null;
          _status = QuestionStatus.noQuestions;
          repository.clearSession();
        }
      }
    } catch (e) {
      _status = QuestionStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
    saveCurrentSession();
  }

  void _restoreHistoryItem(ExamHistoryItem item) {
    _currentQuestion = item.question;
    _selectedOptionId = item.selectedOptionId;
    _selectedAnswerIndex = item.selectedAnswerIndex;
    _answerResult = item.answerResult;
    _answerStatus = item.answerStatus;
    _status = QuestionStatus.loaded;
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
      final currentExcludes = <int>{..._sessionAttemptedIds};
      if (_currentQuestion != null) currentExcludes.add(_currentQuestion!.id);

      final excludeString = currentExcludes.isNotEmpty
          ? currentExcludes.join(',')
          : null;

      final question = await repository.getNextQuestion(
        specialtyId: specialtyId,
        subTopic: subTopic,
        filter: filter,
        exclude: excludeString,
        shuffle: shuffle,
      );

      if (question != null) {
        if (shuffle) {
          final shuffledOptions = List<OptionModel>.from(question.options)..shuffle();
          _prefetchedQuestion = question.copyWith(options: shuffledOptions);
        } else {
          _prefetchedQuestion = question;
        }
      }
    } catch (e) {
      debugPrint('Prefetch failed: $e');
    } finally {
      _isPrefetching = false;
    }
  }

  void selectOption(int optionId, {int? answerIndex}) {
    if (_answerStatus == AnswerStatus.submitted) return;
    _selectedOptionId = optionId;
    if (answerIndex != null) _selectedAnswerIndex = answerIndex;
    if (_historyIndex >= 0 && _historyIndex < _history.length) {
      _history[_historyIndex] = _history[_historyIndex].copyWith(
        selectedOptionId: optionId,
        selectedAnswerIndex: answerIndex,
      );
    }
    notifyListeners();
  }

  Future<void> submitAnswer({String? confidenceLevel, int? answerIndex}) async {
    if (_currentQuestion == null ||
        _selectedOptionId == null ||
        _answerStatus == AnswerStatus.submitting ||
        _answerStatus == AnswerStatus.submitted) {
      return;
    }

    if (answerIndex != null) {
      _selectedAnswerIndex = answerIndex;
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
        _totalAttempted++;
        if (!_isRetryMode) _sessionCorrectCount++;
      } else {
        _totalAttempted++;
        if (!_failedSessionQuestions.any((q) => q.id == _currentQuestion!.id)) {
          _failedSessionQuestions.add(_currentQuestion!);
        }
      }

      if (_historyIndex >= 0 && _historyIndex < _history.length) {
        _history[_historyIndex] = _history[_historyIndex].copyWith(
          selectedOptionId: _selectedOptionId,
          selectedAnswerIndex: _selectedAnswerIndex,
          answerResult: result,
          timeTaken: timeTaken,
          answerStatus: AnswerStatus.submitted,
          isAnswerChecked: true,
        );
      }
    } catch (e) {
      _answerStatus = AnswerStatus.error;
      _errorMessage = e.toString();
      if (e.toString().contains('QUOTA_EXCEEDED')) {
        _status = QuestionStatus.error;
      }
    }
    notifyListeners();
    saveCurrentSession();
  }

  Future<void> toggleBookmark() async {
    if (_currentQuestion == null) return;
    try {
      final newStatus = await repository.toggleBookmark(_currentQuestion!.id);
      _currentQuestion = QuestionModel(
        id: _currentQuestion!.id,
        text: _currentQuestion!.text,
        difficulty: _currentQuestion!.difficulty,
        specialty: _currentQuestion!.specialty,
        options: _currentQuestion!.options,
        isBookmarked: newStatus,
        isPremium: _currentQuestion!.isPremium,
      );
      if (_historyIndex >= 0 && _historyIndex < _history.length) {
        _history[_historyIndex] = _history[_historyIndex].copyWith(
          question: _currentQuestion,
        );
      }
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
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
    
    _failedSessionQuestions.clear();
    _isRetryMode = false;
    _sessionCorrectCount = session.correctCount;

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
