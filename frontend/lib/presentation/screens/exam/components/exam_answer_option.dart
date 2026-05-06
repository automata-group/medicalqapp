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
    Color backgroundColor;
    Color borderColor;

    Color labelBgColor;
    Color labelTextColor;

    switch (state) {
      case AnswerState.idle:
        backgroundColor = Colors.white;
        borderColor = Colors.transparent;
        labelBgColor = Colors.grey[50]!;
        labelTextColor = Colors.grey[400]!;
        break;
      case AnswerState.selected:
        backgroundColor = AppColors.primary.withValues(alpha: 0.05);
        borderColor = AppColors.primary;
        labelBgColor = AppColors.primary;
        labelTextColor = Colors.white;
        break;
      case AnswerState.correct:
        backgroundColor = const Color(0xFFF0FDF4); // bg-green-50
        borderColor = const Color(0xFF34C759); // success green
        labelBgColor = const Color(0xFF34C759);
        labelTextColor = Colors.white;
        break;
      case AnswerState.wrong:
        backgroundColor = const Color(0xFFFEF2F2); // bg-red-50
        borderColor = const Color(0xFFFF3B30); // error red
        labelBgColor = const Color(0xFFFF3B30);
        labelTextColor = Colors.white;
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF368CE2).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
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
                  color: state == AnswerState.idle
                      ? const Color(0xFF334155) // slate-700
                      : Colors.black87,
                ),
              ),
            ),

            // Icon/Status Indicator
            if (state == AnswerState.correct)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF34C759),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              )
            else if (state == AnswerState.wrong)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3B30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
