import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../../main.dart'; // For LocaleProvider
import 'app_components.dart';

// ---------------------------------------------------------------------------
// 1. Complaint Tracking Timeline (Submitted, Assigned, Under Review, Resolved)
// ---------------------------------------------------------------------------
class TimelineStepItem {
  final String title;
  final String timeOrSubtitle;
  final bool isCompleted;
  final bool isInProgress;
  final IconData? icon;

  TimelineStepItem({
    required this.title,
    required this.timeOrSubtitle,
    this.isCompleted = false,
    this.isInProgress = false,
    this.icon,
  });
}

class ComplaintTimeline extends StatelessWidget {
  final List<TimelineStepItem> steps;

  const ComplaintTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(steps.length, (index) {
        final item = steps[index];
        final isLast = index == steps.length - 1;

        Color dotColor;
        Widget dotChild;

        if (item.isCompleted) {
          dotColor = AppColors.normal;
          dotChild = const Icon(Icons.check, size: 14, color: Colors.white);
        } else if (item.isInProgress) {
          dotColor = AppColors.primary;
          dotChild = const StatusDot(type: AppStatusType.normal, size: 8);
        } else {
          dotColor = isDark ? const Color(0xFF2E445C) : const Color(0xFFD2DFEC);
          dotChild = const SizedBox.shrink();
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line and indicator
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: dotChild),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: item.isCompleted
                            ? AppColors.normal
                            : (isDark ? const Color(0xFF2E445C) : const Color(0xFFD2DFEC)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isCompleted || item.isInProgress
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.timeOrSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. LineChartCard (Trend Line Chart with toggle chips)
// ---------------------------------------------------------------------------
class LineChartCard extends StatefulWidget {
  final String title;
  final List<String> metrics;
  final Map<String, List<FlSpot>> metricData;
  final double minY;
  final double maxY;
  final List<String> xLabels;

  const LineChartCard({
    super.key,
    required this.title,
    required this.metrics,
    required this.metricData,
    this.minY = 5.0,
    this.maxY = 9.0,
    required this.xLabels,
  });

  @override
  State<LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  late String _selectedMetric;

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.metrics.isNotEmpty ? widget.metrics.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = widget.metricData[_selectedMetric] ?? [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Toggle Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.metrics.map((m) {
                final isSelected = m == _selectedMetric;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMetric = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.surface2Dark : AppColors.surface2Light),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                        .withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text(
                        val.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < widget.xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              widget.xLabels[idx],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (widget.xLabels.length - 1).toDouble(),
                minY: widget.minY,
                maxY: widget.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. BarChartCard (Rainfall Trend Bar Chart with readable labels)
// ---------------------------------------------------------------------------
class BarChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<double> values;
  final double maxY;

  const BarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    this.maxY = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                        .withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              labels[idx],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: AppColors.primary,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. AppBottomNav (White bar, active blue icon + label + pill, icon bounce)
// ---------------------------------------------------------------------------
class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
        ),
        boxShadow: isDark ? null : AppShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.teal.withValues(alpha: 0.18)
                                  : AppColors.primary.withValues(alpha: 0.12))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? (isDark ? AppColors.teal : AppColors.primary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.teal : AppColors.primary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. LanguageSwitcher Component
// ---------------------------------------------------------------------------
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale.languageCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLangBtn(context, 'English', 'en', currentLang == 'en'),
        const SizedBox(width: 6),
        _buildLangBtn(context, 'मराठी', 'mr', currentLang == 'mr'),
        const SizedBox(width: 6),
        _buildLangBtn(context, 'हिन्दी', 'hi', currentLang == 'hi'),
      ],
    );
  }

  Widget _buildLangBtn(
      BuildContext context, String title, String code, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false)
            .setLocale(Locale(code));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surface2Dark : AppColors.surface2Light),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}
