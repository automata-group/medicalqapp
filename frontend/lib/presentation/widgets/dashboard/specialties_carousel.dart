import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/specialty_provider.dart';
import '../../screens/practice/specialty_topics_screen.dart';
import '../../../core/theme/app_colors.dart';

class SpecialtiesCarousel extends StatelessWidget {
  const SpecialtiesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialtyProvider>(
      builder: (context, provider, child) {
        final specialties = provider.specialties;

        if (provider.isLoading && specialties.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (specialties.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Specialties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(
              height: 156,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: specialties.length,
                itemBuilder: (context, index) {
                  final specialty = specialties[index];
                  return _buildSpecialtyCard(context, specialty);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecialtyCard(BuildContext context, dynamic specialty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpecialtyTopicsScreen(
              specialtyId: specialty.id,
              specialtyName: specialty.name,
            ),
          ),
        );
      },
      child: Container(
        width: 124,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: specialty.icon != null && specialty.icon.contains('/uploads/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.network(
                      'https://healthlicenseprep.com${specialty.icon}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 24),
                    ),
                  )
                : const Icon(Icons.medical_services_rounded, 
                    color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  specialty.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
