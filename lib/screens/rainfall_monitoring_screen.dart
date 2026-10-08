import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/responsive_layout.dart';

/// Screen 9: Rainfall & Ujani Dam Monitoring
/// Job: "Track Solapur seasonal rainfall, Ujani dam reservoir capacity, and rainwater harvesting potential."
class RainfallMonitoringScreen extends StatelessWidget {
  const RainfallMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.rainfallForecast.toUpperCase()),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Ujani Dam Master Storage Fact
              HeroFactCard(
                categoryTag: 'UJANI DAM & WATER RESERVOIR',
                primaryFact: 'Storage: 78.4% • 117.2 TMC',
                supportingDetail: 'Safe monsoon operating level. Adequate drinking water reserves secured for Solapur municipal zone for 180+ days.',
                lastUpdated: 'Irrigation Dept sync 1h ago',
                statusPill: const StatusPill(label: 'Optimal Storage', type: StatusType.ok),
                icon: Icons.water_outlined,
              ),
              const SizedBox(height: AppSpacing.s16),

              // 2. SUPPORTING METRICS
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 3 : 2,
                    childAspectRatio: 1.35,
                    crossAxisSpacing: AppSpacing.s12,
                    mainAxisSpacing: AppSpacing.s12,
                    children: [
                      DataStatCard(
                        title: 'Today\'s Rain',
                        value: '14.2 mm',
                        icon: Icons.umbrella_outlined,
                        color: accent,
                        subtitle: 'Moderate showers',
                      ),
                      DataStatCard(
                        title: 'Season Total',
                        value: '584 mm',
                        icon: Icons.cloud_outlined,
                        color: AppColors.statusOk(context),
                        subtitle: '+8% vs 5-yr avg',
                      ),
                      DataStatCard(
                        title: 'Harvesting Index',
                        value: '82/100',
                        icon: Icons.roofing_outlined,
                        color: AppColors.statusOk(context),
                        subtitle: 'High rooftop refill',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s20),

              // 3. WARD-LEVEL PRECIPITATION
              SectionHeader(
                title: 'SOLAPUR SUB-DISTRICT RAINFALL',
                subtitle: 'Automated weather stations across municipal wards',
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Column(
                  children: [
                    _buildWardRainTile(context, 'North Solapur (Bhavani Peth)', '16.4 mm', 'Normal'),
                    Divider(color: AppColors.border(context), height: 1),
                    _buildWardRainTile(context, 'South Solapur (Kegaon)', '12.8 mm', 'Normal'),
                    Divider(color: AppColors.border(context), height: 1),
                    _buildWardRainTile(context, 'Central Solapur (Navi Peth)', '14.0 mm', 'Normal'),
                    Divider(color: AppColors.border(context), height: 1),
                    _buildWardRainTile(context, 'Barshi Outskirts', '18.2 mm', 'Heavy'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // 4. RAINWATER HARVESTING ADVISORY
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: accent.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: accent.withOpacity(0.3), width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.tips_and_updates_outlined, color: accent, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Civic Rainwater Harvesting Rebate',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Solapur homeowners with functional rooftop filtration qualify for a 5% property water tax rebate.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardRainTile(BuildContext context, String ward, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, size: 16, color: AppColors.accent(context)),
              const SizedBox(width: AppSpacing.s12),
              Text(ward, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
