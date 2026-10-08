import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

/// Screen: Hotel & Commercial Facility Water Management Portal
class HotelDetailScreen extends StatelessWidget {
  const HotelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('HOTEL & COMMERCIAL PORTAL'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Facility Overview Card
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
                            'Balaji Grand Residency',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusAttentionContainer(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'COMMERCIAL',
                              style: TextStyle(color: AppColors.statusAttention(context), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Old Pune Naka, Solapur • 36 Rooms (75% Occupancy)',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem('Kitchen Use', '4.2 kL/day', Icons.restaurant),
                          _buildStatItem('Laundry Use', '3.8 kL/day', Icons.local_laundry_service),
                          _buildStatItem('Tankers Dispatched', '2 Trips', Icons.local_shipping),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Consumption Chart
                Text('Commercial Water Demand (Litres)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              switch (val.toInt()) {
                                case 0: return const Text('Jan', style: TextStyle(fontSize: 10));
                                case 1: return const Text('Feb', style: TextStyle(fontSize: 10));
                                case 2: return const Text('Mar', style: TextStyle(fontSize: 10));
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
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.warning,
                          barWidth: 3,
                          spots: const [
                            FlSpot(0, 240000),
                            FlSpot(1, 230000),
                            FlSpot(2, 255000),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Emergency Tanker Dispatch Action
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Priority commercial water tanker dispatched for Balaji Grand Residency.')),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('BOOK EMERGENCY COMMERCIAL TANKER (10 kL)'),
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
          Icon(icon, size: 20, color: AppColors.warning),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
