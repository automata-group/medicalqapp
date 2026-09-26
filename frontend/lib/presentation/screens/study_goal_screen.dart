import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/toast_utils.dart';
import '../providers/study_goal_provider.dart';
import '../providers/auth_provider.dart';
import 'main_container_screen.dart';

class StudyGoalScreen extends StatelessWidget {
  const StudyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StudyGoalView();
  }
}

class _StudyGoalView extends StatefulWidget {
  const _StudyGoalView();

  @override
  State<_StudyGoalView> createState() => _StudyGoalViewState();
}

class _StudyGoalViewState extends State<_StudyGoalView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudyGoalProvider>();
      if (provider.selectedDate == null) {
        provider.loadGoal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<StudyGoalProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 20.0,
                  vertical: isTablet ? 32.0 : 16.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Container(
                    padding: isTablet ? const EdgeInsets.all(36.0) : EdgeInsets.zero,
                    decoration: isTablet
                        ? BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.setStudyGoal,
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.studyGoalSubtitle,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isTablet ? 36 : 32),

                        // Date Picker Section
                        Text(
                          l10n.examDate,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                          ),
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
                                      onSurface: isDark ? Colors.white : const Color(0xFF1E293B),
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
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.selectedDate == null
                                      ? l10n.selectDate
                                      : '${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}',
                                  style: TextStyle(
                                    color: provider.selectedDate == null
                                        ? Colors.grey
                                        : (isDark ? Colors.white : Colors.black87),
                                    fontSize: 15,
                                    fontWeight: provider.selectedDate == null ? FontWeight.normal : FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.calendar_today_rounded,
                                    color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 36 : 32),

                        // Study Hours Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.dailyStudyHours,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${provider.dailyHours.toInt()} ${l10n.hours}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
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
                                enabledThumbRadius: 12, elevation: 3),
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

                        SizedBox(height: isTablet ? 40 : 36),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isValid && !provider.isLoading
                                ? () async {
                                    final success = await provider.saveGoal();
                                    if (context.mounted) {
                                      if (success) {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool('cached_has_study_plan', true);
                                        if (context.mounted) {
                                          context.read<AuthProvider>().setHasStudyPlan(true);
                                          ToastUtils.showSuccess(context, l10n.studyPlanSaved);
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const MainContainerScreen()),
                                            (route) => false,
                                          );
                                        }
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.primary.withValues(alpha: 0.3),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
