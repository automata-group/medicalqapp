import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/specialty_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../screens/exam/exam_screen.dart';
import 'package:intl/intl.dart';

class ContinueRevisionSection extends StatelessWidget {
  const ContinueRevisionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final revisions = provider.overview?.continueRevision ?? [];

        if (revisions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.continueRevision,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ...revisions.map(
                (item) => _buildRevisionCard(context, item, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevisionCard(
    BuildContext context,
    ContinueRevisionModel item,
    AppLocalizations l10n,
  ) {
    final color = _getColorForSpecialty(item.title);
    final icon = _getIconForSpecialty(item.title);

    return GestureDetector(
      onTap: () {
        // Resolve specialtyId
        int? resolvedId = item.specialtyId;
        if (resolvedId == null) {
          final specialties = context.read<SpecialtyProvider>().specialties;
          final match = specialties
              .where((s) => s.name.toLowerCase() == item.title.toLowerCase())
              .toList();
          if (match.isNotEmpty) resolvedId = match.first.id;
        }

        if (resolvedId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExamScreen(
                specialtyId: resolvedId!.toString(),
                subTopic: item.topicName,
                shuffle: false,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.icon != null && item.icon!.contains('/uploads/')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://healthlicenseprep.com${item.icon}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(icon, color: color),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedName(l10n, item.title),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${_formatTimeAgo(item.timestamp, l10n)} • ${item.topicName ?? _getSubtitle(l10n, item.subtitle)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  l10n.continueAction,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return DateFormat.yMMMd().format(dateTime);
    } else if (difference.inHours > 0) {
      // Assuming you have 'hoursAgo' in l10n: "منذ {count} ساعات"
      return l10n.hoursAgo(difference.inHours, ''); // The second param phase is optional in some contexts
    } else {
      // Add a fallback for minutes if not in l10n yet, or use a simple string
      return '${difference.inMinutes}m';
    }
  }

  String _getSubtitle(AppLocalizations l10n, String subtitle) {
    // Basic mapping, could be extended
    if (subtitle == "Recent Practice") return l10n.recentPractice;
    return subtitle;
  }

  Color _getColorForSpecialty(String name) {
    if (name.toLowerCase().contains('ortho')) return Colors.teal;
    if (name.toLowerCase().contains('endo')) return Colors.purple;
    if (name.toLowerCase().contains('prosth')) return Colors.orange;
    if (name.toLowerCase().contains('perio')) return Colors.pink;
    if (name.toLowerCase().contains('pediatric')) return Colors.green;
    if (name.toLowerCase().contains('surg')) return Colors.red;
    if (name.toLowerCase().contains('restor')) return Colors.blue;
    return AppColors.primary;
  }

  IconData _getIconForSpecialty(String name) {
    if (name.toLowerCase().contains('ortho')) {
      return Icons.sentiment_satisfied_alt;
    }
    if (name.toLowerCase().contains('endo')) return Icons.flash_on;
    if (name.toLowerCase().contains('prosth')) return Icons.build;
    if (name.toLowerCase().contains('perio')) return Icons.cleaning_services;
    if (name.toLowerCase().contains('pediatric')) {
      return Icons.child_care;
    }
    if (name.toLowerCase().contains('surg')) {
      return Icons.local_hospital;
    }
    if (name.toLowerCase().contains('steril') || name.toLowerCase().contains('infect')) {
      return Icons.sanitizer;
    }
    return Icons.medical_services;
  }

  String _getLocalizedName(AppLocalizations l10n, String name) {
    switch (name) {
      case 'Orthodontics':
        return l10n.orthodontics;
      case 'Endodontics':
        return l10n.endodontics;
      case 'Prosthodontics':
        return l10n.prosthodontics;
      case 'Periodontics':
        return l10n.periodontics;
      case 'Pediatric Dentistry':
        return l10n.pediatricDentistry;
      case 'Restorative':
        return l10n.restorative;
      case 'Dental Surgery':
      case 'Oral Surgery':
        return l10n.oralSurgery;
      case 'Sterilization and Infection Control':
        return l10n.infectionControl;
      case 'Oral Medicine & Pathology':
        return l10n.oralMedicine;
      case 'Dental Ethics':
        return l10n.dentalEthics;
      default:
        return name;
    }
  }
}
