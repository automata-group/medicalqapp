import 'package:flutter/material.dart';

class AuthHeroPanel extends StatelessWidget {
  final String? customTitle;
  final String? customSubtitle;

  const AuthHeroPanel({
    super.key,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = customTitle ??
        (isArabic
            ? 'منصة SDLE للتميز الطبي'
            : 'SDLE Medical Excellence');

    final subtitle = customSubtitle ??
        (isArabic
            ? 'شريكك الذكي الشامل لاجتياز اختبار الهيئة السعودية للتخصصات الصحية بأعلى الدرجات'
            : 'Your smart, all-in-one companion to pass the Saudi Medical Licensing Exam with confidence');

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Deep Slate
            Color(0xFF1E3A8A), // Royal Navy
            Color(0xFF0284C7), // Medical Electric Blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient glowing decorative spheres
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 36.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Logo in polished card
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Platform Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Feature cards
                      _buildFeatureTile(
                        icon: Icons.auto_stories_rounded,
                        title: isArabic ? '+3000 سؤال محاكي معتمد' : '3,000+ Verified SDLE Questions',
                        description: isArabic
                            ? 'أسئلة محدثة وفق نمط الهيئة مع شروحات طبية دقيقة ومراجع علمية'
                            : 'Updated questions with comprehensive medical rationales and citations',
                      ),
                      const SizedBox(height: 14),

                      _buildFeatureTile(
                        icon: Icons.timer_outlined,
                        title: isArabic ? 'محاكاة واقعية لقاعة الاختبار' : 'Realistic Exam Simulation',
                        description: isArabic
                            ? 'نظام توقيت معتمد وتجربة تنقل ومراجعة مطابقة للاختبار الرسمي'
                            : 'Official timing, navigation, and review flow to build exam readiness',
                      ),
                      const SizedBox(height: 14),

                      _buildFeatureTile(
                        icon: Icons.psychology_rounded,
                        title: isArabic ? 'المدرب الذكي (AI Mentor)' : 'AI Smart Coach',
                        description: isArabic
                            ? 'تحليل فوري لأدائك لتحديد نقاط القوة والضعف وخطة تقوية مخصصة'
                            : 'Continuous diagnostic analysis of your weaknesses with targeted guidance',
                      ),
                      const SizedBox(height: 32),

                      // Trust badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981), // Emerald pulse
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                isArabic
                                    ? 'موثوق من آلاف أطباء وطبيبات المملكة 🇸🇦'
                                    : 'Trusted by thousands of doctors across Saudi Arabia 🇸🇦',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
