import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mock_exam_provider.dart';

/// Shown between Part 1 and Part 2 of the mock exam.
/// Counts down a 10-minute scheduled break and auto-advances after it ends.
class ExamBreakScreen extends StatefulWidget {
  static const int breakDurationSeconds = 30 * 60; // 30 minutes optional break

  const ExamBreakScreen({super.key});

  @override
  State<ExamBreakScreen> createState() => _ExamBreakScreenState();
}

class _ExamBreakScreenState extends State<ExamBreakScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start the break countdown (default 30 mins, or from exam configuration)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exam = context.read<MockExamProvider>().currentExam;
      final duration = (exam?.breakDuration ?? 30) * 60;
      context.read<MockExamProvider>().startBreakTimer(duration);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MockExamProvider>(
      builder: (ctx, prov, _) {
        final sectionNumber = prov.currentSectionIndex + 2; // Next section
        final totalBreakSeconds = ((prov.currentExam?.breakDuration ?? 30) * 60).toDouble();
        final progress = totalBreakSeconds > 0
            ? (prov.breakSecondsRemaining / totalBreakSeconds).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Break Icon
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            const Color(0xFFD97706).withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                            color: const Color(0xFFF59E0B), width: 2),
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        size: 52,
                        color: Color(0xFFFDE68A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Break label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'فترة استراحة لمدة ${prov.currentExam?.breakDuration ?? 30} دقيقة ${(prov.currentExam?.allowBreakSkip ?? true) ? "(اختيارية)" : ""} ☕',
                      style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'أحسنت! أنهيت القسم الأول بنجاح 🎉',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'توقف المؤقت مؤقتاً. يبدأ القسم $sectionNumber تلقائياً خلال:',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Countdown circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF59E0B)),
                        ),
                      ),
                      Text(
                        prov.breakTimerString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Tips
                  _buildTip('💧', 'اشرب بعض الماء وخذ نفساً عميقاً لتجديد نشاطك'),
                  const SizedBox(height: 10),
                  _buildTip(
                    '🎯',
                    (prov.currentExam?.allowBreakSkip ?? true)
                        ? 'الاستراحة اختيارية ويمكنك المتابعة في أي لحظة'
                        : 'الاستراحة منظمة لتجديد طاقتك الذهنية قبل إكمال الاختبار',
                  ),
                  const SizedBox(height: 36),

                  // Skip break button (or auto-advance notification)
                  if (prov.currentExam?.allowBreakSkip ?? true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => prov.advanceToNextSection(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 6,
                          shadowColor: const Color(0xFFEA580C).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        icon: const Icon(Icons.skip_next_rounded, size: 24),
                        label: Text('تخطي الاستراحة وبدء القسم $sectionNumber الآن'),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, color: Color(0xFFFDE68A), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'سيبدأ القسم التالي تلقائياً عند انتهاء مؤقت الاستراحة',
                            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildTip(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
      ],
    );
  }
}
