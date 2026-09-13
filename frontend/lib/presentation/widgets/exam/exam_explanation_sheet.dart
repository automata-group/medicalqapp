import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamExplanationSheet extends StatelessWidget {
  final bool isCorrect;
  final String correctOptionText;
  final String explanation;
  final double passRate;
  final int averageTimeSeconds;
  final int userTimeSeconds;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const ExamExplanationSheet({
    super.key,
    required this.isCorrect,
    required this.correctOptionText,
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

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    // Result Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.1))
                                : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.1)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect
                                ? (isDark ? const Color(0xFF34D399) : Colors.green)
                                : (isDark ? const Color(0xFFF87171) : Colors.red),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCorrect ? 'Correct!' : 'Incorrect',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect
                                      ? (isDark ? const Color(0xFF34D399) : Colors.green)
                                      : (isDark ? const Color(0xFFF87171) : Colors.red),
                                ),
                              ),
                              if (!isCorrect)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Correct Answer: $correctOptionText',
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Peer Stats Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Pass Rate',
                            '${(passRate * 100).toInt()}%',
                            Icons.pie_chart_outline,
                            AppColors.primary,
                            isDark,
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                          ),
                          _buildStatColumn(
                            'Avg. Time',
                            '${averageTimeSeconds}s',
                            Icons.timer_outlined,
                            Colors.orange,
                            isDark,
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                          ),
                          _buildStatColumn(
                            'Your Time',
                            '${userTimeSeconds}s',
                            Icons.speed,
                            userTimeSeconds <= averageTimeSeconds
                                ? (isDark ? const Color(0xFF34D399) : Colors.green)
                                : (isDark ? const Color(0xFFF87171) : Colors.red),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Explanation Header
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Explanation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Explanation Content
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : Colors.blue.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.blue.shade100,
                        ),
                      ),
                      child: MarkdownBody(
                        data: explanation,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    if (onPrevious != null) ...[
                      OutlinedButton.icon(
                        onPressed: onPrevious,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFF1F5F9) : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
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
                            Icon(Icons.arrow_forward),
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
      },
    );
  }

  Widget _buildStatColumn(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
