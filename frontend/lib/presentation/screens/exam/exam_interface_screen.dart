import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/mock_exam_provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/exam/exam_header.dart';
import '../../widgets/exam/exam_option_card.dart';
import '../../widgets/exam/exam_explanation_sheet.dart';
import 'exam_result_screen.dart';
import 'exam_break_screen.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/utils/specialty_extension.dart';

class ExamInterfaceScreen extends StatefulWidget {
  final String
      mockExamId; // Or pass the model directly if already loaded? ID is safer for nav.

  const ExamInterfaceScreen({super.key, required this.mockExamId});

  @override
  State<ExamInterfaceScreen> createState() => _ExamInterfaceScreenState();
}

class _ExamInterfaceScreenState extends State<ExamInterfaceScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MockExamProvider>()
          .startExam(widget.mockExamId)
          .then((success) {
        if (!mounted) return;
        if (!success) {
          ToastUtils.showError(context, 'Failed to start exam');
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showExplanation(BuildContext context, MockExamProvider provider) {
    if (provider.answerResult == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (sheetContext) => ExamExplanationSheet(
        isCorrect: provider.answerResult!['isCorrect'] ?? false,
        correctOptionText:
            'Check Explanation', // Ideally pass the text or find it from options
        explanation: provider.answerResult!['explanation'] ??
            'No explanation available.',
        passRate: 50.0, // Mock exams don't track detailed global stats yet
        averageTimeSeconds: 60,
        userTimeSeconds: (provider.currentExam?.duration ?? 60) * 60 -
            provider.secondsRemaining,
        onNext: () {
          Navigator.pop(sheetContext);
          if (provider.currentQuestionIndex <
              provider.currentQuestions.length - 1) {
            provider.nextQuestion();
          } else {
            provider.finishExam().then((success) {
              if (context.mounted && success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamResultScreen()),
                );
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Exam?'),
            content: const Text(
                'Are you sure you want to exit? Your progress may be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text('Exit', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: Consumer<MockExamProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.currentQuestion == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            final question = provider.currentQuestion;

            // === SECTION BREAK ===
            if (provider.isAtSectionBreak) {
              return const ExamBreakScreen();
            }

            if (question == null) {
              return const Center(child: Text('No questions loaded.'));
            }

            return SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header
                      ExamHeader(
                        currentQuestionIndex: provider.globalQuestionIndex,
                        totalQuestions: provider.totalQuestions,
                        timeRemaining: provider.timerString,
                        onClose: () => Navigator.of(context).pop(),
                      ),

                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                // Specialty Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${getSpecialtyLocalizedName(question.specialty ?? "General", AppLocalizations.of(context)!)} ${question.topic != null ? "• ${question.topic}" : ""}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Question Text
                                Text(
                                  question.text,
                                  textAlign: TextAlign.left,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                  ),
                                ),
                                const SizedBox(height: 32),

                              // Options
                              ...question.options.asMap().entries.map((entry) {
                                final index = entry.key;
                                final option = entry.value;
                                final labels = ['A', 'B', 'C', 'D'];
                                final isSelected = provider.selectedOptionId ==
                                    option.id.toString();
                                final isSubmitted = provider.isAnswerSubmitted;
                                final isCorrect =
                                    provider.answerResult?['correctOptionId'] ==
                                        option.id.toString();

                                return ExamOptionCard(
                                  id: option.id.toString(),
                                  text: option.text,
                                  label: labels[index % labels.length],
                                  isSelected: isSelected,
                                  isSubmitted: isSubmitted,
                                  isCorrect: isCorrect,
                                  isWrong:
                                      isSubmitted && isSelected && !isCorrect,
                                  onTap: () => provider
                                      .selectOption(option.id.toString()),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),

                  // Bottom Navigation
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: ElevatedButton(
                        onPressed: provider.selectedOptionId == null
                            ? null
                            : () async {
                                if (provider.isAnswerSubmitted) {
                                  if (provider.currentQuestionIndex <
                                      provider.currentQuestions.length - 1) {
                                    provider.nextQuestion();
                                  } else {
                                    // Finish Exam
                                    final success = await provider.finishExam();
                                    if (context.mounted && success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ExamResultScreen(),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  await provider.submitAnswer();
                                  if (context.mounted &&
                                      provider.isAnswerSubmitted) {
                                    _showExplanation(context, provider);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.isAnswerSubmitted
                                  ? (provider.currentQuestionIndex <
                                          provider.currentQuestions.length - 1
                                      ? AppLocalizations.of(context)!.next
                                      : AppLocalizations.of(context)!.finishExam)
                                  : AppLocalizations.of(context)!.submit,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                                provider.isAnswerSubmitted
                                    ? Icons.chevron_left
                                    : Icons.check,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
