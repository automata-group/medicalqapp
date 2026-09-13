import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class WeeklyProgressCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool isTablet;

  const WeeklyProgressCard({
    super.key,
    this.margin,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final overview = provider.overview;
        final accuracy = overview?.accuracy ?? 0;
        final answered = overview?.totalSolved ?? 0;

        return Padding(
          padding: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF137FEC), Color(0xFF1D4ED8), Color(0xFF2563EB)],
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
                  color: const Color(0xFF137FEC).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  left: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  right: -30,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 24),
                  child: Column(
                    mainAxisAlignment: isTablet
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.weeklyProgress,
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$accuracy%',
                                style: TextStyle(
                                  fontSize: isTablet ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: isTablet ? 22 : 24,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 14 : 20),
                      // Bar Chart
                      if (overview != null && overview.activityGraph.isNotEmpty)
                        SizedBox(
                          height: isTablet ? 76 : 64,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: overview.activityGraph.map((data) {
                              final maxCount = overview.activityGraph
                                  .map((e) => e.count)
                                  .reduce((a, b) => a > b ? a : b);
                              final heightFactor =
                                  maxCount > 0 ? data.count / maxCount : 0.0;
                              return _buildBar(
                                heightFactor,
                                isHigh: heightFactor >= 0.8,
                                label: data.day,
                                isTablet: isTablet,
                              );
                            }).toList(),
                          ),
                        )
                      else
                        SizedBox(
                          height: isTablet ? 76 : 64,
                          child: Center(
                            child: Text(
                              l10n.noActivityData,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      SizedBox(height: isTablet ? 14 : 18),
                      // Bottom Row: Answered questions & Streak
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.answeredQuestions(answered),
                              style: TextStyle(
                                fontSize: isTablet ? 11 : 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (overview != null && overview.currentStreak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${overview.currentStreak}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF137FEC),
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  Widget _buildBar(
    double heightFactor, {
    bool isHigh = false,
    String? label,
    bool isTablet = false,
  }) {
    final barWidth = isTablet ? 16.0 : 12.0;
    final effectiveHeight = heightFactor.clamp(0.08, 1.0);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: barWidth,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: effectiveHeight,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: barWidth,
                    decoration: BoxDecoration(
                      gradient: isHigh
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Color(0xFFBAE6FD)],
                            )
                          : null,
                      color: isHigh
                          ? null
                          : (heightFactor > 0.15
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(barWidth / 2),
                      boxShadow: isHigh
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.45),
                                blurRadius: 6,
                                offset: const Offset(0, -1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isHigh ? Colors.white : Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: isHigh ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
