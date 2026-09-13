import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import '../../screens/exam/exam_screen.dart';

class QuestionBankCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool isTablet;

  const QuestionBankCard({
    super.key,
    this.margin,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final totalQuestions = provider.overview?.totalAvailableQuestions ?? 0;

        return Padding(
          padding: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExamScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 18 : 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.questionBank,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.showQuestionCount
                                  ? l10n.questionsAvailable(totalQuestions)
                                  : l10n.practiceAllSpecialtiesSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: isTablet ? 12 : 14,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 16),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 10 : 12,
                                vertical: isTablet ? 5 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    color: Colors.white,
                                    size: isTablet ? 14 : 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.shuffleQuestions,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: isTablet ? 13 : 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: isTablet ? 56 : 72,
                        height: isTablet ? 56 : 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: isTablet ? 28 : 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
