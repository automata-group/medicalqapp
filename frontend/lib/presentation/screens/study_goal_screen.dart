import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_utils.dart';
import '../providers/study_goal_provider.dart';
import 'main_container_screen.dart';

class StudyGoalScreen extends StatelessWidget {
  const StudyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StudyGoalView();
  }
}

class _StudyGoalView extends StatelessWidget {
  const _StudyGoalView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<StudyGoalProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setStudyGoal, // Add to ARB
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.studyGoalSubtitle, // Add to ARB
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Date Picker Section
              Text(
                l10n.examDate, // Add to ARB
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final initial = (provider.selectedDate != null &&
                          !provider.selectedDate!.isBefore(today))
                      ? provider.selectedDate!
                      : today;

                  final date = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 365 * 2)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: const Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    provider.setDate(date);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.selectedDate == null
                            ? l10n.selectDate // Add to ARB
                            : '${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}',
                        style: TextStyle(
                            color: provider.selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Study Hours Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dailyStudyHours, // Add to ARB
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${provider.dailyHours.toInt()} ${l10n.hours}', // Add to ARB
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12, elevation: 2),
                  overlayColor: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: provider.dailyHours,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) => provider.setDailyHours(value),
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isValid && !provider.isLoading
                      ? () async {
                          final success = await provider.saveGoal();
                          // Navigate to Dashboard (Next Phase)
                          // For now, just show a snackbar simulation or print
                          if (context.mounted) {
                            if (success) {
                              ToastUtils.showSuccess(context, l10n.studyPlanSaved);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MainContainerScreen()),
                                (route) => false,
                              );
                            } else {
                              ToastUtils.showError(context, l10n.studyPlanSaveError);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          l10n.continueText,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
