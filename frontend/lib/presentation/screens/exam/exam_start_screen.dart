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
    final isTablet = MediaQuery.of(context).size.width >= 700;
    final provider = context.watch<MockExamProvider>();
    final exams = widget.specialtyId != null 
        ? provider.getExamsBySpecialty(widget.specialtyId!)
        : provider.availableExams;
    final displayExams = exams.isNotEmpty
        ? exams
        : [MockExamProvider.standardMockExamFallback];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.mockExams,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 980 : 640),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 16,
                    vertical: isTablet ? 28 : 20,
                  ),
                  children: [
                    // iPad Executive Hero Banner
                    if (isTablet)
                      _buildHeroBanner(context, isDark),

                    // Exam Cards List
                    for (int i = 0; i < displayExams.length; i++) ...[
                      _ExamCard(exam: displayExams[i], isTablet: isTablet),
                      if (i < displayExams.length - 1)
                        const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Deep Obsidian
            Color(0xFF1E3A8A), // Royal Navy
            Color(0xFF137FEC), // Electric Sapphire
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF137FEC).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'المحاكاة الرسمية المعتمدة 🇸🇦',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'SDLE / SMLE Board Simulator',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'مركز اختبارات المحاكاة الرسمية للهيئة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'عِش التجربة الحقيقية لقاعة اختبار الهيئة السعودية للتخصصات الصحية بتوقيت ونظام وأقسام الاختبار الفعلي مع تقييم ذكي فوري لأدائك',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTopBadge(Icons.timer_outlined, '4 ساعات إجمالية'),
              _buildTopBadge(Icons.menu_book_outlined, '210 أسئلة متوازنة'),
              _buildTopBadge(Icons.coffee_rounded, 'استراحة مجدولة 30 د'),
              _buildTopBadge(Icons.analytics_outlined, 'تحليل نقاط الضعف'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final MockExamModel exam;
  final bool isTablet;

  const _ExamCard({required this.exam, required this.isTablet});

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
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
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
            // Elegant Royal Top Stripe
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF137FEC),
                    Color(0xFF38BDF8),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isTablet ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Row ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medical Simulation Icon Box (Executive Royal Blue)
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E3A8A), Color(0xFF137FEC)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF137FEC).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: isTablet ? 30 : 26,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF137FEC).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF137FEC).withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, size: 13, color: Color(0xFF137FEC)),
                                      SizedBox(width: 5),
                                      Text(
                                        'محاكاة معتمدة • بنك الأسئلة الشامل',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF137FEC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exam.title,
                              style: TextStyle(
                                fontSize: isTablet ? 21 : 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // PRO Badge (Luxury Gold / Emerald)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPremium
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPremium
                                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPremium ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                              size: 16,
                              color: isPremium ? const Color(0xFF10B981) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isPremium ? 'وصول PRO مفعّل' : 'حصري لمشتركي PRO',
                              style: TextStyle(
                                color: isPremium
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
                                    : (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309)),
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
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 4 Structured Feature Tiles (Compact & Polished) ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      return GridView.count(
                        crossAxisCount: isNarrow ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isNarrow ? 3.4 : (isTablet ? 3.3 : 2.8),
                        children: [
                          _SpecTile(
                            icon: Icons.layers_rounded,
                            iconColor: const Color(0xFF4F46E5),
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
                            iconColor: const Color(0xFF7C3AED),
                            title: 'تغطية الأسئلة',
                            value: 'أسئلة عشوائية شاملة',
                            subtitle: 'تغطي كافة التخصصات والأنماط',
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- Value Checklist (What to expect) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        _buildFeaturePill(Icons.computer_rounded, 'بيئة محاكية لبرومتريك', isDark),
                        _buildFeaturePill(Icons.flag_outlined, 'تأجيل ومراجعة الأسئلة', isDark),
                        _buildFeaturePill(Icons.analytics_outlined, 'تحليل ذكي فوري للأداء', isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Action Button (Royal Sapphire Medical Blue) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPremium
                              ? const [Color(0xFF0F766E), Color(0xFF0D9488)]
                              : const [Color(0xFF1E3A8A), Color(0xFF137FEC)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isPremium ? const Color(0xFF0D9488) : const Color(0xFF137FEC))
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
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
                          isPremium ? Icons.play_circle_fill_rounded : Icons.workspace_premium_rounded,
                          color: isPremium ? Colors.white : const Color(0xFFFFD700),
                          size: 22,
                        ),
                        label: Text(
                          isPremium
                              ? 'بدء اختبار المحاكاة الكاملة (210 أسئلة)'
                              : 'الترقية إلى باقة PRO لفتح اختبار المحاكاة',
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

                  const SizedBox(height: 14),

                  // --- Reassurance / Limit Status ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPremium ? Icons.verified_rounded : Icons.shield_outlined,
                        size: 16,
                        color: isPremium ? const Color(0xFF10B981) : const Color(0xFF137FEC),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPremium
                            ? 'حسابك PRO يتمتع بوصول كامل وغير محدود لكافة اختبارات المحاكاة'
                            : 'معتمد ومطابق لأحدث معايير الهيئة السعودية للتخصصات الصحية 🇸🇦',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isPremium
                              ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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

  Widget _buildFeaturePill(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF137FEC)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
      ],
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
            width: 38,
            height: 38,
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

