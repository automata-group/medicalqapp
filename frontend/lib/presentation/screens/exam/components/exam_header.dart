import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class ExamHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String timeElapsed;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onBookmark;
  final VoidCallback onReport;
  final VoidCallback? onPrevious;
  final bool hasPrevious;
  final bool isBookmarked;
  final bool showTotalQuestions;

  const ExamHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.timeElapsed,
    required this.progress,
    required this.onClose,
    required this.onBookmark,
    required this.onReport,
    this.onPrevious,
    this.hasPrevious = false,
    this.isBookmarked = false,
    this.showTotalQuestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool shouldShowTotal = showTotalQuestions && totalQuestions > 0;
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            // Top Row: Back button (if available), Timer, Question Count, Actions
            Row(
              children: [
                // Previous Question Button
                if (hasPrevious && onPrevious != null) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPrevious,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        timeElapsed,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Question Count
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      questionText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Actions Row (Bookmark, Report, Close)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bookmark
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.star : Icons.star_border,
                        color: isBookmarked ? Colors.amber : Colors.grey[400],
                        size: 22,
                      ),
                      onPressed: onBookmark,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 4),

                    // Report
                    IconButton(
                      icon: Icon(Icons.warning_amber_rounded,
                          color: Colors.grey[400], size: 20),
                      onPressed: onReport,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 6),

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
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 20, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (shouldShowTotal) ...[
              const SizedBox(height: 10),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
