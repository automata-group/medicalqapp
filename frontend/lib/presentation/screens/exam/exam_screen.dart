import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/question_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import 'components/exam_header.dart';
import 'components/exam_question_card.dart';
import 'components/exam_answer_option.dart';
import 'components/exam_explanation_sheet.dart';
import 'components/exam_report_sheet.dart';
import '../subscription/pricing_screen.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/theme/app_colors.dart';
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
  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<QuestionProvider>();
      provider.clearCurrentQuestion();
      
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
          return;
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
    final provider = context.read<QuestionProvider>();
    if (_isAnswerChecked || provider.isCurrentAnswerChecked) return;
    setState(() {
      _selectedAnswerIndex = index;
    });

    provider.selectOption(optionId, answerIndex: index);
    _confirmAnswer('medium', index);
  }

  void _confirmAnswer(String confidence, int index) async {
    final provider = context.read<QuestionProvider>();
    await provider.submitAnswer(confidenceLevel: confidence, answerIndex: index);

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
    final provider = context.read<QuestionProvider>();
    final question = provider.currentQuestion;
    if (question == null) return;

    ExamReportSheet.show(context, questionId: question.id);
  }

  void _showExplanationSheet(bool isCorrect) {
    final provider = context.read<QuestionProvider>();
    final question = provider.currentQuestion;
    final result = provider.answerResult;

    if (question == null || result == null) return;

    final correctOption = question.options.firstWhere(
        (o) => o.id == result.correctOptionId,
        orElse: () => question.options.first);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) {
        return ExamExplanationSheet(
          isCorrect: result.isCorrect,
          correctAnswerText: correctOption.text,
          explanation: result.explanation ?? 'No explanation provided.',
          passRate: result.stats?.passRate ?? 0,
          averageTimeSeconds: result.stats?.averageTimeSeconds ?? 0,
          userTimeSeconds: provider.lastTimeTaken,
          onPrevious: provider.hasPreviousQuestion
              ? () {
                  Navigator.pop(sheetContext);
                  _loadPreviousQuestion();
                }
              : null,
          onNext: () {
            Navigator.pop(sheetContext);
            _loadNextQuestion();
          },
        );
      },
    );
  }

  void _loadPreviousQuestion() {
    final provider = context.read<QuestionProvider>();
    provider.loadPreviousQuestion();
    setState(() {
      _selectedAnswerIndex = provider.selectedAnswerIndex;
      _isAnswerChecked = provider.isCurrentAnswerChecked;
    });
  }

  void _loadNextQuestion() {
    final provider = context.read<QuestionProvider>();
    final user = context.read<AuthProvider>().user;
    final isPremium = user?.isPremium ?? false;

    // Check quota for free accounts before advancing to next question
    if (!isPremium && !provider.hasNextInHistory) {
      final isSpecialty = widget.specialtyId != null || widget.subTopic != null;
      final maxAllowed = isSpecialty ? 15 : 30;

      // When the user has answered the quota questions (15 for specialty, 30 for question bank)
      // and clicks "Next" to go to the next question:
      if (provider.sessionAttemptedIds.length >= maxAllowed || provider.currentQuestionIndex >= maxAllowed) {
        provider.triggerQuotaExceeded();
        return;
      }
    }

    if (provider.hasNextInHistory) {
      provider.loadNextQuestion(
        specialtyId: widget.specialtyId,
        subTopic: widget.subTopic,
        filter: widget.filter,
        shuffle: widget.shuffle,
      );
      setState(() {
        _selectedAnswerIndex = provider.selectedAnswerIndex;
        _isAnswerChecked = provider.isCurrentAnswerChecked;
      });
      return;
    }

    setState(() {
      _selectedAnswerIndex = null;
      _isAnswerChecked = false;
    });
    _startTimer();
    provider.loadNextQuestion(
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
    final l10n = AppLocalizations.of(context);
    final String subTopic = session.subTopic ?? l10n?.thisSpecialty ?? 'this specialty';
    final String title = l10n?.resumeSessionTitle ?? 'Resume Session?';
    final String content = l10n != null
        ? l10n.resumeSessionContent(subTopic)
        : 'You have a saved session in $subTopic.\nWould you like to continue from where you left off?';
    final String startNewText = l10n?.startNew ?? 'Start New';
    final String continueText = l10n?.continueAction ?? 'Continue';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(startNewText, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(continueText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final question = provider.currentQuestion;
    final isAnswerSubmitted = _isAnswerChecked || provider.isCurrentAnswerChecked;
    final activeAnswerIndex = _selectedAnswerIndex ?? provider.selectedAnswerIndex;
    final l10n = AppLocalizations.of(context)!;

    if (provider.status == QuestionStatus.loading || provider.status == QuestionStatus.initial) {
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
      final isSpecialty = widget.specialtyId != null || widget.subTopic != null;
      final quotaTitle = isSpecialty
          ? l10n.specialtyLimitReached
          : l10n.questionBankLimitReached;

      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing crown badge
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withValues(alpha: 0.25),
                            const Color(0xFFD97706).withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        l10n.proMembership,
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      quotaTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.upgradeToProPrompt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade100.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature highlights list
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          _buildProFeatureRow(l10n.tagQuestionsCount),
                          const Divider(color: Colors.white12, height: 16),
                          _buildProFeatureRow(l10n.tagSmartExplanations),
                          const Divider(color: Colors.white12, height: 16),
                          _buildProFeatureRow(l10n.tagExamSimulation),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Upgrade Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PricingScreen()),
                          );
                          if (!context.mounted) return;
                          final user = context.read<AuthProvider>().user;
                          if (user?.isPremium == true) {
                            final provider = context.read<QuestionProvider>();
                            provider.resetSession();
                            provider.loadNextQuestion(
                              specialtyId: widget.specialtyId,
                              subTopic: widget.subTopic,
                              filter: widget.filter,
                              shuffle: widget.shuffle,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                        ),
                        child: Text(
                          l10n.upgradeToProBtn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.backToHome,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (provider.status == QuestionStatus.error) {
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
                Text(
                  l10n.failedToLoadQuestion,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? l10n.checkConnectionPrompt,
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
                      label: Text(l10n.retry),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Previous Question support
            ExamHeader(
              currentQuestionIndex: provider.currentQuestionIndex,
              totalQuestions: _getTotalQuestions(provider),
              timeElapsed: _formatTime(_secondsElapsed),
              progress: _calculateProgress(provider),
              isBookmarked: provider.isBookmarked,
              hasPrevious: provider.hasPreviousQuestion,
              onPrevious: _loadPreviousQuestion,
              showTotalQuestions: !widget.shuffle && dashboardProvider.showQuestionCount,
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
                    // Question Card
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 600),
                      tween: ColorTween(
                        begin: Colors.transparent,
                        end: (isAnswerSubmitted &&
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
                              if (isAnswerSubmitted)
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
                      AnswerState state = AnswerState.idle;

                      if (isAnswerSubmitted) {
                        if (provider.answerResult?.correctOptionId == option.id) {
                          state = AnswerState.correct;
                        } else if (index == activeAnswerIndex) {
                          state = AnswerState.wrong;
                        }
                      } else if (activeAnswerIndex == index) {
                        state = AnswerState.selected;
                      }

                      return ExamAnswerOption(
                        label: String.fromCharCode(65 + index),
                        text: option.text,
                        state: state,
                        onTap: () => _handleAnswerSelection(index, option.id),
                      );
                    }),

                    // Inline Review Actions when question is answered
                    if (isAnswerSubmitted && provider.answerResult != null) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showExplanationSheet(provider.answerResult!.isCorrect);
                              },
                              icon: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                              label: Text(l10n.viewExplanation, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loadNextQuestion,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(l10n.nextQuestion, style: const TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 80),
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
    if (widget.shuffle) return 0;
    if (provider.totalInCategory > 0) {
      return provider.totalInCategory;
    }
    return 0;
  }

  double _calculateProgress(QuestionProvider provider) {
    final total = _getTotalQuestions(provider);
    if (total == 0) return 0;
    return (provider.currentQuestionIndex + 1) / total;
  }

  Widget _buildProFeatureRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
