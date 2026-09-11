import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExamOptionCard extends StatelessWidget {
  final String id;
  final String text;
  final String label; // A, B, C, D
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isSubmitted;
  final VoidCallback onTap;

  const ExamOptionCard({
    super.key,
    required this.id,
    required this.text,
    required this.label,
    required this.isSelected,
    this.isCorrect = false,
    this.isWrong = false,
    this.isSubmitted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDark ? Theme.of(context).cardColor : Colors.white;
    Color borderColor = isDark ? const Color(0xFF334155) : Colors.transparent;
    Color labelBgColor = isDark ? const Color(0xFF0F172A) : Colors.grey.shade50;
    Color labelTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400;

    if (isSubmitted) {
      if (isCorrect) {
        backgroundColor = AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.05);
        borderColor = AppColors.primary;
        labelBgColor = AppColors.primary;
        labelTextColor = Colors.white;
      } else if (isWrong && isSelected) {
        backgroundColor = Colors.red.withValues(alpha: isDark ? 0.2 : 0.05);
        borderColor = Colors.red;
        labelBgColor = Colors.red.withValues(alpha: isDark ? 0.3 : 0.1);
        labelTextColor = Colors.red;
      } else {
        // Unselected options during result
        borderColor = isDark ? const Color(0xFF334155) : Colors.transparent;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.05);
        labelTextColor = AppColors.primary;
      }
    }

    return GestureDetector(
      onTap: isSubmitted ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              // Label Box (A, B, C...)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelTextColor,
                    fontSize: 16,
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
                    fontSize: 14, // medium font
                    fontWeight: FontWeight.w500,
                    color: isSelected && !isSubmitted
                        ? AppColors.primary
                        : (isDark ? const Color(0xFFF1F5F9) : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Checkmark/Radio
              if (isSubmitted && isCorrect)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF64748B) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
