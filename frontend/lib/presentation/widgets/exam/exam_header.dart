import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExamHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final String timeRemaining;
  final VoidCallback onClose;

  const ExamHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.timeRemaining,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (0.0 to 1.0)
    final double progress =
        totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      timeRemaining,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend', // or system default
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Text
              Text(
                'السؤال ${currentQuestionIndex + 1} من $totalQuestions', // Localize
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              // Close Button
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // dark:bg-slate-800
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600, // dark:text-slate-300
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      ),
    );
  }
}
