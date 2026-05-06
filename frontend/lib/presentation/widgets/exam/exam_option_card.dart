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
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color labelBgColor = Colors.grey.shade50;
    Color labelTextColor = Colors.grey.shade400;

    if (isSubmitted) {
      if (isCorrect) {
        backgroundColor = AppColors.primary.withValues(
            alpha:
                0.05); // Using primary as success/correct in this theme context? Or green? Design uses primary/blue for correct in one state, but usually green is success.
        // The design says: "bg-primary/5 ... border-primary ... text-white ... bg-primary" for correct. The primary is blue (#368ce2).
        // Let's stick to the design.
        backgroundColor = AppColors.primary.withValues(alpha: 0.05);
        borderColor = AppColors.primary;
        labelBgColor = AppColors.primary;
        labelTextColor = Colors.white;
      } else if (isWrong && isSelected) {
        // Design doesn't explicitly show wrong state but usually red.
        // For now, I'll use standard red for wrong to be clear, or stick to design guidelines if they exist.
        // studymod.html only shows "Correct State Simulation".
        // I'll use red for consistency with QuickExam.
        backgroundColor = Colors.red.withValues(alpha: 0.05);
        borderColor = Colors.red;
        labelBgColor = Colors.red.withValues(alpha: 0.1);
        labelTextColor = Colors.red;
      } else {
        // Unselected options during result
        borderColor = Colors.transparent;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.05);
        // Label could change color too if needed
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
                style: TextStyle(
                  fontSize: 14, // medium font
                  fontWeight: FontWeight.w500,
                  color: isSelected && !isSubmitted
                      ? AppColors.primary
                      : Colors.black87,
                ),
              ),
            ),
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
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
