import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../../data/models/mock_exam_model.dart';
import '../../data/models/question_model.dart';

class MockExamProvider extends ChangeNotifier {
  final MockExamRepository repository;

  MockExamProvider({required this.repository});

  List<MockExamModel> _availableExams = [];
  bool _isLoading = false;
  String? _error;

  List<MockExamModel> get availableExams => _availableExams;
  List<MockExamModel> getExamsBySpecialty(int specialtyId) => 
      _availableExams.where((e) => e.specialtyId == specialtyId).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Exam Session State
  Timer? _timer;
  int _secondsRemaining = 0;
  String? _selectedOptionId;
  bool _isAnswerSubmitted = false;
  Map<String, dynamic>?
      _answerResult; // {isCorrect, correctOptionId, explanation}

  int get secondsRemaining => _secondsRemaining;
  String? get selectedOptionId => _selectedOptionId;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  Map<String, dynamic>? get answerResult => _answerResult;
  int get globalQuestionIndex {
    if (_currentExam == null) return _currentQuestionIndex;
    int previousQuestionsCount = 0;
    for (int i = 0; i < _currentSectionIndex; i++) {
      previousQuestionsCount += _currentExam!.sections[i].questionCount;
    }
    return previousQuestionsCount + _currentQuestionIndex;
  }

  String get timerString {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentExam?.totalQuestions ?? 0;

  // Exam Session State
  String? _currentAttemptId;
  MockExamModel? _currentExam;
  List<QuestionModel> _currentQuestions = [];
  int _currentQuestionIndex = 0;

  MockExamModel? get currentExam => _currentExam;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  QuestionModel? get currentQuestion => _currentQuestions.isNotEmpty &&
          _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;

  // Section transition state
  int _currentSectionIndex = 0;
  bool _isAtSectionBreak = false;
  int _breakSecondsRemaining = 0;
  Timer? _breakTimer;

  int get currentSectionIndex => _currentSectionIndex;
  bool get isAtSectionBreak => _isAtSectionBreak;
  int get breakSecondsRemaining => _breakSecondsRemaining;
  bool get isLastSection =>
      _currentExam == null ||
      _currentSectionIndex >= _currentExam!.sections.length - 1;

  String get breakTimerString {
    final m = (_breakSecondsRemaining / 60).floor();
    final s = _breakSecondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> loadMockExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _availableExams = await repository.getMockExams();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startExam(String mockExamId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await repository.startMockExam(mockExamId);
      _currentAttemptId = data['attemptId'].toString();

      // Find from available exams if loaded
      try {
        _currentExam =
            _availableExams.firstWhere((e) => e.id.toString() == mockExamId);
      } catch (_) {
        _currentExam = null;
      }

      // Parse sections from API response
      final rawSections = data['sections'] as List<dynamic>?;
      final parsedSections = rawSections
              ?.map((e) =>
                  MockExamSectionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      if (_currentExam != null) {
        if (_currentExam!.sections.isEmpty && parsedSections.isNotEmpty) {
          _currentExam = _currentExam!.copyWith(sections: parsedSections);
        }
      } else {
        _currentExam = MockExamModel(
          id: int.tryParse(mockExamId) ?? 0,
          title: data['examTitle'] ?? 'Mock Exam',
          totalQuestions: parsedSections.fold<int>(
              0, (sum, s) => sum + s.questionCount),
          duration: 60,
          price: 0.0,
          isPremium: false,
          sections: parsedSections,
        );
      }

      final activeSections = (_currentExam?.sections.isNotEmpty ?? false)
          ? _currentExam!.sections
          : parsedSections;

      // Load section (either last active or first)
      if (activeSections.isNotEmpty) {
        // Start Timer
        _secondsRemaining = (_currentExam?.duration ?? 60) * 60;
        _startTimer();

        final sectionIdToLoad = data['lastActiveSectionId']?.toString() ??
            activeSections[0].id.toString();

        // Update current section index based on loaded ID
        _currentSectionIndex = activeSections
            .indexWhere((s) => s.id.toString() == sectionIdToLoad);
        if (_currentSectionIndex == -1) _currentSectionIndex = 0;

        await loadSection(sectionIdToLoad);
      } else {
        _error = 'No sections available in this exam.';
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSection(String sectionId) async {
    if (_currentAttemptId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _currentQuestions =
          await repository.getSectionQuestions(_currentAttemptId!, sectionId);
      _currentQuestionIndex = 0;
      if ((_currentExam?.totalQuestions ?? 0) == 0 &&
          _currentQuestions.isNotEmpty) {
        _currentExam =
            _currentExam?.copyWith(totalQuestions: _currentQuestions.length);
      }
      _resetQuestionState();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Auto-submit or finish logic
      }
    });
  }

  void selectOption(String optionId) {
    if (_isAnswerSubmitted) return;
    _selectedOptionId = optionId;
    notifyListeners();
  }

  Future<void> submitAnswer() async {
    if (_currentAttemptId == null ||
        _selectedOptionId == null ||
        currentQuestion == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await repository.submitAnswer(_currentAttemptId!,
          currentQuestion!.id.toString(), _selectedOptionId!, 0);

      _isAnswerSubmitted = true;
      _answerResult = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      _resetQuestionState();
      notifyListeners();
    } else if (!isLastSection) {
      // Show break screen before next section
      _isAtSectionBreak = true;
      notifyListeners();
    }
    // If last section and last question — UI calls finishExam()
  }

  /// Called when user taps "Start Next Section" after the break.
  Future<void> advanceToNextSection() async {
    _breakTimer?.cancel();
    _isAtSectionBreak = false;
    _currentSectionIndex++;
    // Reset timer for next section
    _secondsRemaining = (_currentExam!.duration) * 60;
    _startTimer();
    // Load next section questions
    final nextSection = _currentExam!.sections[_currentSectionIndex];
    await loadSection(nextSection.id.toString());
  }

  void startBreakTimer(int breakSeconds) {
    _breakTimer?.cancel();
    _breakSecondsRemaining = breakSeconds;
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_breakSecondsRemaining > 0) {
        _breakSecondsRemaining--;
        notifyListeners();
      } else {
        t.cancel();
        // Auto-advance after break
        advanceToNextSection();
      }
    });
  }

  void _resetQuestionState() {
    _selectedOptionId = null;
    _isAnswerSubmitted = false;
    _answerResult = null;
  }

  // Exam Result State
  Map<String, dynamic>? _examResult;
  Map<String, dynamic>? get examResult => _examResult;

  Future<bool> finishExam() async {
    if (_currentAttemptId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await repository.completeMockExam(_currentAttemptId!);
      _examResult = result;
      _timer?.cancel();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breakTimer?.cancel();
    super.dispose();
  }
}
