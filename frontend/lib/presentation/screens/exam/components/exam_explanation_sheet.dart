import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExamExplanationSheet extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswerText;
  final String explanation;
  final int passRate;
  final int averageTimeSeconds;
  final int userTimeSeconds;
  final VoidCallback onNext;
  final bool canRetry;
  final int attemptsLeft;
  final VoidCallback? onRetry;
  final VoidCallback? onGiveUp;

  const ExamExplanationSheet({
    super.key,
    required this.isCorrect,
    required this.correctAnswerText,
    required this.explanation,
    required this.passRate,
    required this.averageTimeSeconds,
    required this.userTimeSeconds,
    required this.onNext,
    this.canRetry = false,
    this.attemptsLeft = 0,
    this.onRetry,
    this.onGiveUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Result Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF34C759).withValues(alpha: 0.1)
                            : const Color(0xFFFF3B30).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF3B30),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'Correct!' : 'Incorrect',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          if (!isCorrect && !canRetry)
                            Text(
                              'Correct Answer: $correctAnswerText',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (!isCorrect && canRetry)
                            Text(
                              '$attemptsLeft attempts remaining',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (!canRetry) ...[
                  // Statistics Box (New)
                  if (passRate > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                              'Pass Rate', '$passRate%', Icons.trending_up),
                          Container(
                              width: 1,
                              height: 40,
                              color: Colors.blue.withValues(alpha: 0.1)),
                          _buildStatItem('Average Time',
                              '${averageTimeSeconds}s', Icons.timer),
                          Container(
                              width: 1,
                              height: 40,
                              color: Colors.blue.withValues(alpha: 0.1)),
                          _buildStatItem(
                              'Your Time', '${userTimeSeconds}s', Icons.person),
                        ],
                      ),
                    ),

                  // Explanation Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Why is this the answer?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          explanation,
                          style: const TextStyle(
                            height: 1.6,
                            fontSize: 14,
                            color: Color(0xFF475569), // slate-600
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Retry Prompt Content
                  const SizedBox(height: 16),
                  Center(
                    child: Icon(Icons.refresh,
                        size: 48, color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Don\'t give up just yet! Take another look at the question and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 100), // Spacing for bottom button
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: canRetry
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            if (onRetry != null) onRetry!();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (onGiveUp != null) {
                                    onGiveUp!();
                                  } else {
                                    Navigator.pop(context);
                                    onNext();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: Colors.grey.shade300)),
                                child: Text('Give Up & Show Answer',
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold)),
                              ))
                    ],
                  )
                : ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
