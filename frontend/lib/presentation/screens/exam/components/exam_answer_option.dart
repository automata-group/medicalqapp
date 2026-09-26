import 'package:flutter/material.dart';

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
        borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        labelBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
        labelTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
        break;
      case AnswerState.selected:
        backgroundColor = isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
            : const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF2563EB);
        labelBgColor = const Color(0xFF2563EB);
        labelTextColor = Colors.white;
        textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
        break;
      case AnswerState.correct:
        backgroundColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFF0FDF4); // bg-green-50
        borderColor = const Color(0xFF10B981); // success green
        labelBgColor = const Color(0xFF10B981);
        labelTextColor = Colors.white;
        textColor = isDark ? const Color(0xFFECFDF5) : const Color(0xFF064E3B);
        break;
      case AnswerState.wrong:
        backgroundColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: state == AnswerState.idle ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: state == AnswerState.idle
                  ? (isDark
                      ? Colors.transparent
                      : const Color(0xFF0F172A).withValues(alpha: 0.04))
                  : (state == AnswerState.correct
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : (state == AnswerState.wrong
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : const Color(0xFF2563EB).withValues(alpha: 0.15))),
              blurRadius: state == AnswerState.idle ? 10 : 16,
              offset: const Offset(0, 3),
            ),
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
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontWeight: state == AnswerState.idle
                        ? FontWeight.w500
                        : FontWeight.w600,
                    fontSize: 15,
                    height: 1.45,
                    color: textColor,
                  ),
                ),
              ),

              // Icon/Status Indicator
              if (state == AnswerState.correct)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                )
              else if (state == AnswerState.wrong)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
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
