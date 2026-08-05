import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/question_provider.dart';
import 'components/exam_explanation_sheet.dart';

class QuickExamScreen extends StatefulWidget {
  const QuickExamScreen({super.key});

  @override
  State<QuickExamScreen> createState() => _QuickExamScreenState();
}

class _QuickExamScreenState extends State<QuickExamScreen> {
  @override
  void initState() {
    super.initState();
    // Load first question on init
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<QuestionProvider>();
        provider.resetSession();
        provider.loadNextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickExam),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          if (provider.status == QuestionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == QuestionStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadNextQuestion(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.status == QuestionStatus.noQuestions) {
            final total = provider.sessionTotalCount;
            final correct = provider.sessionCorrectCount;
            final mistakes = total - correct;
            final accuracy = total > 0 ? (correct / total * 100).round() : 0;
            final hasMistakes = provider.hasMistakes;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          accuracy >= 80
                              ? Icons.emoji_events
                              : (accuracy >= 50
                                  ? Icons.thumb_up
                                  : Icons.menu_book),
                          size: 80,
                          color: accuracy >= 80
                              ? Colors.amber
                              : (accuracy >= 50 ? Colors.blue : Colors.orange)),
                      const SizedBox(height: 16),
                      Text(
                        accuracy >= 80
                            ? 'Outstanding! 🎉'
                            : (accuracy >= 50
                                ? 'Good Job! 👍'
                                : 'Keep Practice! 💪'),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You completed $total questions.',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickStatCard(
                              'Accuracy', '$accuracy%', Colors.blue),
                          _buildQuickStatCard(
                              'Correct', '$correct', Colors.green),
                          _buildQuickStatCard(
                              'Mistakes', '$mistakes', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 48),
                      if (hasMistakes)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              provider.startRetryMode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            label: const Text('Retry Mistakes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      SizedBox(height: hasMistakes ? 16 : 0),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back to Home',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB))),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }

          final question = provider.currentQuestion;
          if (question == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question Header (Specialty + Difficulty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (question.specialty != null)
                      Chip(
                        label: Text(
                          question.specialty!,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                      ),
                    Chip(
                      label: Text(
                        question.difficulty.toUpperCase(),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Text
                Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Options
                ...question.options.map((option) {
                  final isSelected = provider.selectedOptionId == option.id;
                  final isSubmitted =
                      provider.answerStatus == AnswerStatus.submitted;

                  Color borderColor = const Color(0xFFE2E8F0);
                  Color backgroundColor = Colors.white;

                  if (isSubmitted && provider.answerResult != null) {
                    if (option.id == provider.answerResult!.correctOptionId) {
                      borderColor = Colors.green;
                      backgroundColor = Colors.green.withValues(alpha: 0.1);
                    } else if (isSelected &&
                        !provider.answerResult!.isCorrect) {
                      borderColor = Colors.red;
                      backgroundColor = Colors.red.withValues(alpha: 0.1);
                    }
                  } else if (isSelected) {
                    borderColor = AppColors.primary;
                    backgroundColor = AppColors.primary.withValues(alpha: 0.05);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: isSubmitted
                          ? null
                          : () => provider.selectOption(option.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border.all(
                            color: borderColor,
                            width: (isSelected ||
                                    (isSubmitted &&
                                        (option.id ==
                                                provider.answerResult
                                                    ?.correctOptionId ||
                                            (isSelected &&
                                                !provider
                                                    .answerResult!.isCorrect))))
                                ? 2
                                : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? borderColor
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                color: isSelected ? borderColor : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF475569),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.selectedOptionId == null ||
                            provider.answerStatus == AnswerStatus.submitting
                        ? null
                        : () async {
                            if (provider.answerStatus ==
                                AnswerStatus.submitted) {
                              _showExplanationSheet(context, provider);
                            } else {
                              await provider.submitAnswer();
                              if (context.mounted &&
                                  provider.answerStatus ==
                                      AnswerStatus.submitted) {
                                _showExplanationSheet(context, provider);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                    ),
                    child: provider.answerStatus == AnswerStatus.submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            provider.answerStatus == AnswerStatus.submitted
                                ? 'View Details & Next'
                                : l10n.submit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExplanationSheet(BuildContext context, QuestionProvider provider) {
    final question = provider.currentQuestion;
    final result = provider.answerResult;

    if (question == null || result == null) return;

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
      builder: (sheetContext) {
        return ExamExplanationSheet(
          // Need to import this at top!
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
                  provider.retryCurrentQuestion();
                }
              : null,
          onNext: () {
            Navigator.pop(sheetContext); // Close sheet
            provider.loadNextQuestion();
          },
        );
      },
    );
  }

  Widget _buildQuickStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
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
} // End of _QuickExamScreenState
