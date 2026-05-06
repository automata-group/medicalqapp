import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/specialty_provider.dart';
import '../../screens/practice/specialty_topics_screen.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/utils/toast_utils.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final activities = provider.recentActivities;

        // Show loading or empty state properly
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (activities.isEmpty) {
          // Optional: Show empty state message
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.keepRevising,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ...activities.map(
                (activity) => Column(
                  children: [
                    _buildActivityItem(context, activity: activity, l10n: l10n),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required RecentActivityModel activity,
    required AppLocalizations l10n,
  }) {
    IconData icon;
    Color color;

    // Simple mapping for demonstration. Ideal way is to have backend send icon/color or map ID
    // Check specialty name for keywords
    final specialtyLower = activity.specialtyName.toLowerCase();
    if (specialtyLower.contains('cardio')) {
      icon = Icons.favorite;
      color = Colors.red;
    } else if (specialtyLower.contains('neuro')) {
      icon = Icons.psychology;
      color = Colors.purple;
    } else if (specialtyLower.contains('pediatric')) {
      icon = Icons.child_care;
      color = Colors.orange;
    } else {
      icon = Icons.assignment_outlined;
      color = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        // Find specialtyId from Provider using the name
        int? resolvedId;
        final specialties = context.read<SpecialtyProvider>().specialties;
        final match = specialties
            .where(
              (s) =>
                  s.name.toLowerCase() == activity.specialtyName.toLowerCase(),
            )
            .toList();
        if (match.isNotEmpty) resolvedId = match.first.id;

        if (resolvedId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SpecialtyTopicsScreen(
                specialtyId: resolvedId!,
                specialtyName: activity.specialtyName,
              ),
            ),
          );
        } else {
          ToastUtils.showError(context, 'Specialty not found locally.');
        }
      },
      child: Container(
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
              child:
                  activity.specialtyIcon != null &&
                      activity.specialtyIcon!.contains('/uploads/')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://healthlicenseprep.com${activity.specialtyIcon}',
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
                    activity.specialtyName, // Display Specialty as Title
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    _formatTimeAgo(activity.createdAt, l10n),
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
                  l10n.resume,
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
    if (difference.inDays > 1) {
      return '${difference.inDays} days ago'; // Fallback as daysAgo might not be in arb yet
    } else if (difference.inDays == 1) {
      return l10n.yesterday(
        'Correlation',
      ); // Argument ignored if not used, or just 'Yesterday'
    } else if (difference.inHours >= 1) {
      return l10n.hoursAgo(difference.inHours, '');
    } else {
      return 'Just now';
    }
  }
}
