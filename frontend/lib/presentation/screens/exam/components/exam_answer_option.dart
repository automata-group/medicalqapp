import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum AnswerState { idle, selected, correct, wrong }

class ExamAnswerOption extends StatelessWidget {
  final String label; // "A", "B", etc.
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  const ExamAnswerOption({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color borderColor;
    Color labelBgColor;
    Color labelTextColor;
    Color textColor;

    switch (state) {
      case AnswerState.idle:
        backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        borderColor = isDark ? const Color(0xFF334155) : Colors.transparent;
        labelBgColor = isDark ? const Color(0xFF0F172A) : Colors.grey[50]!;
        labelTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
        textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155);
        break;
      case AnswerState.selected:
        backgroundColor = isDark
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.primary.withValues(alpha: 0.05);
        borderColor = AppColors.primary;
        labelBgColor = AppColors.primary;
        labelTextColor = Colors.white;
        textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
        break;
      case AnswerState.correct:
        backgroundColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFF0FDF4); // bg-green-50
        borderColor = const Color(0xFF10B981); // success green
        labelBgColor = const Color(0xFF10B981);
        labelTextColor = Colors.white;
        textColor = isDark ? const Color(0xFFECFDF5) : const Color(0xFF064E3B);
        break;
      case AnswerState.wrong:
        backgroundColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
            : const Color(0xFFFEF2F2); // bg-red-50
        borderColor = const Color(0xFFEF4444); // error red
        labelBgColor = const Color(0xFFEF4444);
        labelTextColor = Colors.white;
        textColor = isDark ? const Color(0xFFFEF2F2) : const Color(0xFF7F1D1D);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF368CE2).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              // Label (A, B, C...)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: labelTextColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),

              // Icon/Status Indicator
              if (state == AnswerState.correct)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                )
              else if (state == AnswerState.wrong)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? const Color(0xFF475569) : Colors.grey[300]!,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
