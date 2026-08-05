import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/question_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'components/exam_header.dart';
import 'components/exam_question_card.dart';
import 'components/exam_answer_option.dart';
import 'components/exam_explanation_sheet.dart';
import '../subscription/pricing_screen.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../data/models/session_model.dart';

class ExamScreen extends StatefulWidget {
  final String? specialtyId;
  final String? subTopic;
  final String? filter;
  final bool shuffle;
  final bool autoResume;

  const ExamScreen({
    super.key,
    this.specialtyId,
    this.subTopic,
    this.filter,
    this.shuffle = true,
    this.autoResume = false,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  // Local state to manage UI animation/interaction
  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;
  Timer? _timer;
  int _secondsElapsed = 0;

  // Report State
  final _reportReasonController = TextEditingController();
  String _selectedReportReason = 'typo';

  @override
  void initState() {
    super.initState();
    // Clear old question immediately to avoid "ghosting" from previous sessions
    context.read<QuestionProvider>().clearCurrentQuestion();
    _startTimer();
    // Ensure fresh state on entry
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<QuestionProvider>();
      
      await provider.checkActiveSession(
        specialtyId: widget.specialtyId,
        subTopic: widget.subTopic,
        sessionType: widget.subTopic != null ? 'topic' : (widget.specialtyId != null ? 'specialty' : 'general'),
      );

      if (mounted && provider.activeSessionToResume != null) {
        final session = provider.activeSessionToResume!;
        
        if (widget.autoResume) {
          await provider.restoreSession(session);
          return;
        }

        final resume = await _showResumeDialog(session);
        
        if (resume == true) {
          await provider.restoreSession(session);
          return; // Skip normal initialization
        } else if (resume == false) {
          provider.discardActiveSession();
        }
      }

      provider.resetSession();
      provider.loadNextQuestion(
        specialtyId: widget.specialtyId,
        subTopic: widget.subTopic,
        filter: widget.filter,
        shuffle: widget.shuffle,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handleAnswerSelection(int index, int optionId) {
    if (_isAnswerChecked) return; // Prevent changing after check
    setState(() {
      _selectedAnswerIndex = index;
    });

    // Select in provider
    context.read<QuestionProvider>().selectOption(optionId);

    // AUTO-SUBMIT immediately as per user request
    _confirmAnswer('medium');
  }

  void _confirmAnswer(String confidence) async {
    final provider = context.read<QuestionProvider>();
    await provider.submitAnswer(confidenceLevel: confidence);

    // Check result
    if (provider.answerResult != null) {
      if (!mounted) return;
      setState(() {
        _isAnswerChecked = true;
      });

      if (mounted) {
        _showExplanationSheet(provider.answerResult!.isCorrect);
      }
    }
  }

  void _showReportDialog() {
    _reportReasonController.clear();
    _selectedReportReason = 'typo';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              title: const Text('Report Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReportReason,
                      decoration: const InputDecoration(labelText: 'Reason'),
                      items: const [
                        DropdownMenuItem(
                            value: 'typo', child: Text('Typo/Formatting')),
                        DropdownMenuItem(
                            value: 'scientific_error',
                            child: Text('Scientific Error')),
                        DropdownMenuItem(
                            value: 'wrong_answer',
                            child: Text('Wrong Answer Key')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedReportReason = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reportReasonController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<QuestionProvider>();
                    final navigator = Navigator.of(dialogContext);

                    final success = await provider.submitReport(
                      _selectedReportReason,
                      _reportReasonController.text,
                    );
                    navigator.pop();
                    if (mounted) {
                      if (success) {
                        ToastUtils.showSuccess(context, 'Report submitted successfully.');
                      } else {
                        ToastUtils.showError(context, 'Failed to submit report.');
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExplanationSheet(bool isCorrect) {
    // Capture snapshot BEFORE state changes to avoid null crash
    final provider = context.read<QuestionProvider>();
    final question = provider.currentQuestion;
    final result = provider.answerResult;

    if (question == null || result == null) return;

    // Find correct answer text
    final correctOption = question.options.firstWhere(
        (o) => o.id == result.correctOptionId,
        orElse: () => question.options.first);

    final canRetry = !result.isCorrect && provider.currentQuestionAttempts < 3;
    final attemptsLeft = 3 - provider.currentQuestionAttempts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return ExamExplanationSheet(
          isCorrect: result.isCorrect,
          correctAnswerText: correctOption.text,
          explanation: result.explanation ?? 'No explanation provided.',
          passRate: result.stats?.passRate ?? 0,
          averageTimeSeconds: result.stats?.averageTimeSeconds ?? 0,
          userTimeSeconds: provider.lastTimeTaken,
          canRetry: canRetry,
          attemptsLeft: attemptsLeft,
          onRetry: canRetry
              ? () {
                  setState(() {
                    _selectedAnswerIndex = null;
                    _isAnswerChecked = false;
                  });
                  provider.retryCurrentQuestion();
                }
              : null,
          onGiveUp: canRetry
              ? () {
                  Navigator.pop(context); // Close sheet
                  provider.giveUpCurrentQuestion();
                  _showExplanationSheet(false); // Re-show sheet without retry
                }
              : null,
          onNext: () {
            Navigator.pop(context); // Close sheet
            _loadNextQuestion();
          },
        );
      },
    );
  }

  void _loadNextQuestion() {
    setState(() {
      _selectedAnswerIndex = null;
      _isAnswerChecked = false;
    });
    _startTimer();
    context.read<QuestionProvider>().loadNextQuestion(
          specialtyId: widget.specialtyId,
          subTopic: widget.subTopic,
          filter: widget.filter,
          shuffle: widget.shuffle,
        );
  }


  void _exitExam() {
    context.read<DashboardProvider>().refreshStatsSilently();
    Navigator.pop(context);
  }

  Future<bool?> _showResumeDialog(SessionModel session) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Resume Session?'),
        content: Text(
          'You have a saved session in ${session.subTopic ?? 'this specialty'}.\n'
          'Would you like to continue from where you left off?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Start New', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionProvider>();
    final question = provider.currentQuestion;

    if (provider.status == QuestionStatus.loading || provider.status == QuestionStatus.initial) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (provider.showOfflineButton) ...[
                const SizedBox(height: 32),
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n.connectionTimeout,
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.loadNextQuestion(
                      specialtyId: widget.specialtyId,
                      subTopic: widget.subTopic,
                      filter: widget.filter,
                      forceOffline: true,
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.startOffline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (provider.status == QuestionStatus.error &&
        provider.errorMessage != null &&
        provider.errorMessage!.contains('QUOTA_EXCEEDED')) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'You have reached your free limit of 15 questions for this specialty.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upgrade to PRO to unlock unlimited questions, AI explanations, and mock exams.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PricingScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upgrade to PRO',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (provider.status == QuestionStatus.error) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load the question',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadNextQuestion,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.loadNextQuestion(
                          specialtyId: widget.specialtyId,
                          subTopic: widget.subTopic,
                          filter: widget.filter,
                          forceOffline: true,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.startOffline),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.status == QuestionStatus.noQuestions) {
      final total = provider.sessionTotalCount;
      final correct = provider.sessionCorrectCount;
      final mistakes = total - correct;
      final accuracy = total > 0 ? (correct / total * 100).round() : 0;
      final hasMistakes = provider.hasMistakes;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF1E293B),
          title: const Text('Session Summary',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (accuracy >= 70 ? Colors.green : Colors.blue).withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(
                    accuracy >= 80
                        ? Icons.emoji_events_rounded
                        : (accuracy >= 50 ? Icons.check_circle_rounded : Icons.info_outline_rounded),
                    size: 80,
                    color: accuracy >= 80 ? Colors.amber : (accuracy >= 50 ? Colors.green : Colors.blue),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  accuracy >= 80 ? 'Excellent Work!' : (accuracy >= 50 ? 'Good Effort!' : 'Keep Practicing!'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have completed all questions in this session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Accuracy', '$accuracy%', Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Solved', '$total', Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Correct', '$correct', Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Mistakes', '$mistakes', Colors.red)),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                if (hasMistakes)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.startRetryMode();
                        _startTimer();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Review Mistakes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    ),
                    child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (question == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // background-light
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ExamHeader(
              currentQuestionIndex: provider.sessionTotalCount,
              totalQuestions: _getTotalQuestions(provider),
              timeElapsed: _formatTime(_secondsElapsed),
              progress: _calculateProgress(provider),
              isBookmarked: provider.isBookmarked,
              onBookmark: () async {
                await provider.toggleBookmark();
                if (context.mounted) {
                  ToastUtils.showInfo(
                    context,
                    provider.isBookmarked
                        ? 'Question Bookmarked ⭐'
                        : 'Bookmark Removed',
                  );
                }
              },
              onReport: _showReportDialog,
              onClose: _exitExam,
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    // Question (Animated Mastery Growth)
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 800),
                      tween: ColorTween(
                        begin: Colors.transparent,
                        end: (_isAnswerChecked &&
                                provider.answerResult?.isCorrect == true)
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      builder: (context, color, child) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: color ?? Colors.grey.withValues(alpha: 0.1),
                              width: 2,
                            ),
                            boxShadow: [
                              if (_isAnswerChecked)
                                BoxShadow(
                                  color: (provider.answerResult?.isCorrect == true ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                            ],
                          ),
                          child: ExamQuestionCard(
                            specialtyName: question.specialty ?? 'General',
                            questionText: question.text,
                            imageUrl: question.imageUrl,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      // Determine state
                      AnswerState state = AnswerState.idle;

                      if (_isAnswerChecked) {
                        if (provider.answerResult?.correctOptionId ==
                            option.id) {
                          state = AnswerState.correct;
                        } else if (index == _selectedAnswerIndex) {
                          state = AnswerState.wrong;
                        }
                      } else if (_selectedAnswerIndex == index) {
                        state = AnswerState.selected;
                      }

                      return ExamAnswerOption(
                        label: String.fromCharCode(65 + index), // A, B, C, D
                        text: option.text,
                        state: state,
                        onTap: () => _handleAnswerSelection(index, option.id),
                      );
                    }),



                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalQuestions(QuestionProvider provider) {
    // Only return the total if we have it from the server
    if (provider.totalInCategory > 0) {
      return provider.totalInCategory;
    }
    return 0; // Header will handle 0 as "Unknown Total"
  }

  double _calculateProgress(QuestionProvider provider) {
    final total = _getTotalQuestions(provider);
    if (total == 0) return 0;
    return provider.sessionTotalCount / total;
  }
} // End of _ExamScreenState
