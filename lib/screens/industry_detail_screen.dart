import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

/// Screen: Industrial Manufacturing Water & ETP Monitoring Portal
class IndustryDetailScreen extends StatelessWidget {
  const IndustryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('INDUSTRIAL ETP PORTAL'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Facility Identity
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
                            'Solapur Textile Processors Pvt Ltd',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusInfoContainer(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ZLD CERTIFIED',
                              style: TextStyle(color: AppColors.info, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plot C-14, Chincholi MIDC Phase 2 • License #MPCB-4412',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem('Process Water', '48 kL/day', Icons.water_drop, AppColors.info),
                          _buildStatItem('Recycled (ETP)', '42 kL/day', Icons.recycling, AppColors.normal),
                          _buildStatItem('Recycle Rate', '87.5%', Icons.eco, AppColors.normal),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Environmental Quality Compliance Card
                Text('Real-time Effluent (ETP) Compliance', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      _buildQualityRow('Discharge pH', '7.4', 'Permissible: 6.5 - 8.5', true),
                      const Divider(height: 16),
                      _buildQualityRow('BOD (Biochemical Oxygen)', '18 mg/L', 'Permissible: < 30 mg/L', true),
                      const Divider(height: 16),
                      _buildQualityRow('COD (Chemical Oxygen)', '110 mg/L', 'Permissible: < 250 mg/L', true),
                      const Divider(height: 16),
                      _buildQualityRow('Total Dissolved Solids (TDS)', '1250 ppm', 'Permissible: < 2100 ppm', true),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Industrial Document / Compliance Upload
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload MPCB audit compliance certificate.')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('SUBMIT MPCB ENVIRONMENTAL AUDIT REPORT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String metric, String val, String norm, bool isOk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(norm, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 6),
            Icon(isOk ? Icons.check_circle : Icons.warning, color: isOk ? AppColors.normal : AppColors.critical, size: 16),
          ],
        ),
      ],
    );
  }
}
