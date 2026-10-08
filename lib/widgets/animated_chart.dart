import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AnimatedChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color? color;
  final double? minX;
  final double? maxX;
  final double? minY;
  final double? maxY;
  final String semanticLabel;

  const AnimatedChart({
    super.key,
    required this.spots,
    this.color,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.semanticLabel = 'Telemetry chart',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chartColor = color ?? AppColors.accent(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final labelStyle = TextStyle(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      fontSize: 10,
    );

    return Semantics(
      label: semanticLabel,
      child: RepaintBoundary(
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.surface(context),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y}',
                      TextStyle(
                        color: chartColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 5,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                axisNameWidget: Text('TIME (H)', style: labelStyle.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(value.toInt().toString(), style: labelStyle),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text('PSI', style: labelStyle.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: labelStyle),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: AppColors.border(context), width: 1.0),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: chartColor,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 2.5,
                    color: chartColor,
                    strokeWidth: 1,
                    strokeColor: isDark ? AppColors.surfaceDark : Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: chartColor.withOpacity(0.12),
                ),
              ),
            ],
          ),
          duration: disableAnimations ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
