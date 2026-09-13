import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/mock_exam_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/mock_exam_model.dart';
import 'exam_interface_screen.dart';
import '../subscription/pricing_screen.dart';

class ExamStartScreen extends StatefulWidget {
  final int? specialtyId;
  const ExamStartScreen({super.key, this.specialtyId});

  @override
  State<ExamStartScreen> createState() => _ExamStartScreenState();
}

class _ExamStartScreenState extends State<ExamStartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MockExamProvider>().loadMockExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MockExamProvider>();
    final exams = widget.specialtyId != null 
        ? provider.getExamsBySpecialty(widget.specialtyId!)
        : provider.availableExams;
    final displayExams = exams.isNotEmpty
        ? exams
        : [MockExamProvider.standardMockExamFallback];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.mockExams,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Theme.of(context).cardColor : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : Colors.black,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: displayExams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final exam = displayExams[index];
                    return _ExamCard(exam: exam);
                  },
                ),
              ),
            ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final MockExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;
    final isPremium = user?.isPremium ?? false;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Decorative subtle top stripe
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium
                      ? [const Color(0xFF0D9488), const Color(0xFF14B8A6), const Color(0xFF06B6D4)]
                      : [const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFEA580C)],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Row ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medical Simulation Icon Box
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'محاكاة معتمدة • بنك الأسئلة الشامل',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              exam.title,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // PRO Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF78350F).withValues(alpha: 0.6), const Color(0xFF451A03).withValues(alpha: 0.6)]
                                : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPremium ? 'PRO مفعل' : 'حصري لمشتركي PRO',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    exam.description != null && exam.description!.isNotEmpty
                        ? exam.description!
                        : 'محاكاة كاملة للاختبار الفعلي: قسمان (105 أسئلة لكل قسم)، ساعتان لكل قسم مع استراحة 30 دقيقة اختيارية بينهما. جميع الأسئلة عشوائية من بنك الأسئلة.',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 4 Structured Feature Tiles (2x2 Grid) ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      return GridView.count(
                        crossAxisCount: isNarrow ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isNarrow ? 3.4 : 2.6,
                        children: [
                          _SpecTile(
                            icon: Icons.layers_rounded,
                            iconColor: const Color(0xFF6366F1),
                            title: 'هيكل الاختبار',
                            value: 'قسمان (105 أسئلة / قسم)',
                            subtitle: 'إجمالي 210 أسئلة متوازنة',
                            isDark: isDark,
                          ),
                          _SpecTile(
                            icon: Icons.timer_outlined,
                            iconColor: const Color(0xFF0284C7),
                            title: 'الزمن المخصص',
                            value: 'ساعتان لكل قسم (120 د)',
                            subtitle: 'إجمالي 4 ساعات للاختبار',
                            isDark: isDark,
                          ),
                          _SpecTile(
                            icon: Icons.coffee_rounded,
                            iconColor: const Color(0xFF059669),
                            title: 'فترة الاستراحة',
                            value: '30 دقيقة بين القسمين',
                            subtitle: 'اختيارية مع إمكانية التخطي',
                            isDark: isDark,
                          ),
                          _SpecTile(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: const Color(0xFF9333EA),
                            title: 'تغطية الأسئلة',
                            value: 'أسئلة عشوائية شاملة',
                            subtitle: 'تغطي كافة التخصصات والأنماط',
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- Action Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPremium
                              ? [const Color(0xFF0D9488), const Color(0xFF0F766E)]
                              : [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isPremium ? const Color(0xFF0D9488) : const Color(0xFFEA580C))
                                .withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!isPremium) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PricingScreen(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ExamInterfaceScreen(
                                  mockExamId: exam.id.toString(),
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          isPremium ? Icons.play_circle_fill_rounded : Icons.lock_open_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          isPremium ? 'بدء اختبار المحاكاة الكاملة' : 'ترقية الحساب إلى PRO لبدء الاختبار',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- Reassurance / Limit Status ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPremium ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                        size: 15,
                        color: isPremium ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPremium
                            ? 'حسابك PRO يتمتع بوصول كامل وغير محدود لكافة الاختبارات والأسئلة دون أي ليميت'
                            : 'اختبارات المحاكاة الكاملة مخصصة حصرياً لأعضاء باقة PRO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPremium
                              ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
                              : (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;

  const _SpecTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
