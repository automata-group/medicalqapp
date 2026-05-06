import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/performance_stat_model.dart';
import '../../../core/theme/app_colors.dart';

class PerformanceChartWidget extends StatelessWidget {
  final List<PerformanceStatModel> stats;
  final bool isMonthly;

  const PerformanceChartWidget({
    super.key,
    required this.stats,
    this.isMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFFE2E8F0),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval:
                    isMonthly ? (stats.length / 5).clamp(1, 10).toDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= stats.length) {
                    return const SizedBox.shrink();
                  }
                  final date = stats[index].date;
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      isMonthly
                          ? DateFormat('d/M').format(date)
                          : DateFormat('E').format(date),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (stats.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            // Total Questions Line (Subtle context)
            LineChartBarData(
              spots: _generateSpots(isTotal: true),
              isCurved: true,
              color: AppColors.primary.withValues(alpha: 0.15),
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Correct Answers Line (Premium Main Line)
            LineChartBarData(
              spots: _generateSpots(isTotal: false),
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show dots on every few points if monthly to avoid clutter
                  if (isMonthly && index % 2 != 0) {
                    return FlDotCirclePainter(radius: 0);
                  }
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2.5,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    barSpot.y.toInt().toString(),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (stats.isEmpty) return 10;
    int max = 0;
    for (var stat in stats) {
      if (stat.total > max) max = stat.total;
    }
    return (max + 5).toDouble();
  }

  List<FlSpot> _generateSpots({required bool isTotal}) {
    return List.generate(stats.length, (index) {
      final stat = stats[index];
      return FlSpot(index.toDouble(),
          isTotal ? stat.total.toDouble() : stat.correct.toDouble());
    });
  }
}
