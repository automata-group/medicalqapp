import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class ExamHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String timeRemaining;
  final VoidCallback onClose;
  final bool showTotalQuestions;

  const ExamHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.timeRemaining,
    required this.onClose,
    this.showTotalQuestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool shouldShowTotal = showTotalQuestions && totalQuestions > 0;

    // Calculate progress (0.0 to 1.0)
    final double progress =
        shouldShowTotal ? (currentQuestionIndex + 1) / totalQuestions : 0.0;

    final String questionText = l10n != null
        ? (shouldShowTotal
            ? l10n.questionNumberWithTotal(currentQuestionIndex + 1, totalQuestions)
            : l10n.questionNumber(currentQuestionIndex + 1))
        : (shouldShowTotal
            ? 'Question ${currentQuestionIndex + 1} of $totalQuestions'
            : 'Question ${currentQuestionIndex + 1}');

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.15),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Timer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        timeRemaining,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Text (Expanded with single line & ellipsis)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      questionText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Close Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (shouldShowTotal) ...[
              const SizedBox(height: 10),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
