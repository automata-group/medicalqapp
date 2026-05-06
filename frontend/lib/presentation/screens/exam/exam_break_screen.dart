import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mock_exam_provider.dart';

/// Shown between Part 1 and Part 2 of the mock exam.
/// Counts down a 10-minute scheduled break and auto-advances after it ends.
class ExamBreakScreen extends StatefulWidget {
  static const int breakDurationSeconds = 10 * 60; // 10 minutes

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

    // Start the break countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MockExamProvider>()
          .startBreakTimer(ExamBreakScreen.breakDurationSeconds);
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
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Break Icon
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            const Color(0xFF1E40AF).withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                            color: const Color(0xFF3B82F6), width: 2),
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        size: 56,
                        color: Color(0xFF93C5FD),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Break label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              const Color(0xFF3B82F6).withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'Break Time ☕',
                      style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Well done! You finished the first part',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Part $sectionNumber starts in:',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15),
                  ),
                  const SizedBox(height: 32),

                  // Countdown circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: prov.breakSecondsRemaining /
                              ExamBreakScreen.breakDurationSeconds,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6)),
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
                  const SizedBox(height: 48),

                  // Tips
                  _buildTip('💧', 'Drink water and take a deep breath'),
                  const SizedBox(height: 12),
                  _buildTip('🎯', 'Focus again — the next part is easy'),
                  const SizedBox(height: 48),

                  // Skip break button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => prov.advanceToNextSection(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text('Start Part $sectionNumber Now'),
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
