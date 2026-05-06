import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExamHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String timeElapsed;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onBookmark;
  final VoidCallback onReport;
  final bool isBookmarked;

  const ExamHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.timeElapsed,
    required this.progress,
    required this.onClose,
    required this.onBookmark,
    required this.onReport,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          // Top Row: Timer, Question Count, Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      timeElapsed,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                        color: AppColors
                            .primary, // Using primary color for timer text too
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Question Count
              Text(
                totalQuestions > 0 
                  ? 'Question ${currentQuestionIndex + 1} of $totalQuestions'
                  : 'Question ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
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
                      size: 24,
                    ),
                    onPressed: onBookmark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),

                  // Report
                  IconButton(
                    icon: Icon(Icons.warning_amber_rounded,
                        color: Colors.grey[400], size: 22),
                    onPressed: onReport,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),

                  // Close Button
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.close, size: 20, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

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
      ),
    );
  }
}
