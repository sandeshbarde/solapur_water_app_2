import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

/// Screen: Housing Society Water Management Portal
class HousingDetailScreen extends StatefulWidget {
  const HousingDetailScreen({super.key});

  @override
  State<HousingDetailScreen> createState() => _HousingDetailScreenState();
}

class _HousingDetailScreenState extends State<HousingDetailScreen> {
  int _flats = 48;
  int _tankCapacity = 45000;
  double _dailyAvgConsumption = 18500;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('HOUSING SOCIETY PORTAL'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Society Header Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shree Siddheshwar CHS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusOkContainer(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'METER ACTIVE',
                              style: TextStyle(color: AppColors.statusOk(context), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plot 42, Near D-Mart, Jule Solapur • Ward 3',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem('Total Flats', '$_flats', Icons.apartment),
                          _buildStatItem('Tank Capacity', '${_tankCapacity ~/ 1000} kL', Icons.water),
                          _buildStatItem('Daily Avg', '${_dailyAvgConsumption ~/ 1000} kL', Icons.speed),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Monthly Water Consumption Chart
                Text(
                  'Monthly Water Consumption (Litres)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 700000,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              switch (val.toInt()) {
                                case 0: return const Text('Jan', style: TextStyle(fontSize: 10));
                                case 1: return const Text('Feb', style: TextStyle(fontSize: 10));
                                case 2: return const Text('Mar', style: TextStyle(fontSize: 10));
                                case 3: return const Text('Apr', style: TextStyle(fontSize: 10));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (val, meta) {
                              return Text('${(val / 1000).toInt()}k', style: const TextStyle(fontSize: 9));
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 540000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 510000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 565000, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 590000, color: accent, width: 16, borderRadius: BorderRadius.circular(4))]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Bills & Utility Actions
                Text('Municipal Utility Bills', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('March 2026 Water Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('₹8,475 • Paid on 15 Mar 2026', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusOkContainer(context),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('PAID', style: TextStyle(color: AppColors.statusOk(context), fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Request Tanker / Pipeline Upgrade CTA
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMC Housing bulk water upgrade request submitted.')),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('REQUEST BULK SUPPLY / TANKER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
