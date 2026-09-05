import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/subscription/pricing_screen.dart';

class SubscriptionBannerCard extends StatelessWidget {
  const SubscriptionBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isPremium = user?.isPremium == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PricingScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                  : const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isPremium ? Colors.black : const Color(0xFF312E81))
                    .withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPremium
                            ? const [Colors.green, Color(0xFF059669)]
                            : const [Color(0xFFFFB800), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isPremium
                                  ? Colors.green
                                  : const Color(0xFFFFB800))
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPremium ? Icons.check_circle : Icons.star,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPremium ? 'PRO نشط' : 'SDLE PRO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                isPremium
                    ? 'عضويتك المميزة مفعلة ✨'
                    : 'استعد لاختبار الهيئة مع باقات PRO 🚀',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPremium
                    ? 'وصول كامل لجميع بنوك الأسئلة، امتحانات المحاكاة غير المحدودة وتحليلات الذكاء الاصطناعي.'
                    : 'افتح جميع التخصصات المغلقة، نماذج الامتحانات الوزارية، ومزايا الذكاء الاصطناعي.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPremium ? Icons.settings : Icons.workspace_premium_rounded,
                      color: isPremium ? Colors.white : const Color(0xFFFFB800),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPremium ? 'إدارة خطة الاشتراك' : 'استعراض خطط الاشتراك والأسعار',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
