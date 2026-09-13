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
  final VoidCallback? onPrevious;

  const ExamExplanationSheet({
    super.key,
    required this.isCorrect,
    required this.correctAnswerText,
    required this.explanation,
    required this.passRate,
    required this.averageTimeSeconds,
    required this.userTimeSeconds,
    required this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, -5),
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
                color: isDark ? const Color(0xFF334155) : Colors.grey[200],
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
                            ? (isDark
                                ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                                : const Color(0xFF34C759).withValues(alpha: 0.1))
                            : (isDark
                                ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                                : const Color(0xFFFF3B30).withValues(alpha: 0.1)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF34C759))
                            : (isDark ? const Color(0xFFF87171) : const Color(0xFFFF3B30)),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isCorrect
                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D))
                                  : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                            ),
                          ),
                          if (!isCorrect)
                            Text(
                              'Correct Answer: $correctAnswerText',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Box
                if (passRate > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Pass Rate', '$passRate%', Icons.trending_up, isDark),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? const Color(0xFF334155) : Colors.blue.withValues(alpha: 0.1),
                        ),
                        _buildStatItem('Average Time', '${averageTimeSeconds}s', Icons.timer, isDark),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? const Color(0xFF334155) : Colors.blue.withValues(alpha: 0.1),
                        ),
                        _buildStatItem('Your Time', '${userTimeSeconds}s', Icons.person, isDark),
                      ],
                    ),
                  ),

                // Explanation Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Why is this the answer?',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        explanation,
                        style: TextStyle(
                          height: 1.6,
                          fontSize: 14,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for bottom button
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : Colors.grey[100]!,
                ),
              ),
            ),
            child: Row(
              children: [
                if (onPrevious != null) ...[
                  OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFFF1F5F9) : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 20, color: isDark ? const Color(0xFF60A5FA) : Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
