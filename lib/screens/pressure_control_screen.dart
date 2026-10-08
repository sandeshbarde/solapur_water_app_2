import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

/// Screen 14: Pressure & Valve Regulation
/// Job: "Monitor and manually regulate pressure valves across Solapur wards."
class PressureControlScreen extends StatefulWidget {
  const PressureControlScreen({super.key});

  @override
  State<PressureControlScreen> createState() => _PressureControlScreenState();
}

class _PressureControlScreenState extends State<PressureControlScreen> {
  final List<Map<String, dynamic>> _zones = [
    {'name': 'Ward 08 Central', 'pressure': 22.5, 'status': 'CRITICAL', 'critical': true},
    {'name': 'Ward 12 Industrial', 'pressure': 24.0, 'status': 'LOW', 'critical': false},
    {'name': 'Ward 04 Residential', 'pressure': 45.0, 'status': 'OPTIMAL', 'critical': false},
    {'name': 'DMA South 01 (Kegaon)', 'pressure': 38.5, 'status': 'OPTIMAL', 'critical': false},
  ];

  Future<void> _normalizeZone(int index) async {
    final zoneName = _zones[index]['name'];
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Regulate Pressure: $zoneName',
      actionDescription: 'You are adjusting gate valve aperture to re-establish nominal 42.0 PSI head pressure for $zoneName.',
      consequences: [
        'Valve will modulate dynamically over the next 2 minutes.',
        'Downstream consumer meters will receive calibrated pressure.',
        'Action is logged in municipal water telemetry.',
      ],
      confirmLabel: 'Confirm Regulation',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _zones[index]['pressure'] = 42.0;
      _zones[index]['status'] = 'OPTIMAL';
      _zones[index]['critical'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusOk(context),
        content: Text('Gate valves adjusted for $zoneName. Pressure normalized to 42.0 PSI.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final criticalCount = _zones.where((z) => z['critical'] == true).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PRESSURE & VALVE REGULATION'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Network Status
              HeroFactCard(
                categoryTag: 'DISTRIBUTION SECTOR HEADS',
                primaryFact: criticalCount > 0
                    ? '$criticalCount Critical Zone(s) Requiring Head Modulation'
                    : 'All Sector Pressures Within 30-55 PSI',
                supportingDetail: criticalCount > 0
                    ? 'Ward 08 Central is experiencing head drop (22.5 PSI). Booster pump regulation recommended.'
                    : 'Hydraulic gradient balanced across all 4 municipal monitoring zones.',
                statusPill: StatusPill(
                  label: criticalCount > 0 ? 'Critical' : 'Balanced',
                  type: criticalCount > 0 ? StatusType.critical : StatusType.ok,
                ),
                icon: Icons.speed,
              ),
              const SizedBox(height: AppSpacing.s16),

              // 2. ZONE REGULATION CARDS
              SectionHeader(
                title: 'SECTOR DISTRIBUTION ZONES',
                subtitle: 'Tap equalize to modulate individual sector gate valves',
              ),
              ..._zones.asMap().entries.map((entry) {
                final idx = entry.key;
                final zone = entry.value;
                final isCritical = zone['critical'] as bool;
                final isLow = zone['status'] == 'LOW';

                StatusType statusType = StatusType.ok;
                if (isCritical) statusType = StatusType.critical;
                if (isLow) statusType = StatusType.attention;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context), width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            zone['name'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          StatusPill(
                            label: zone['status'] as String,
                            type: statusType,
                            isCompact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 18, color: AppColors.accent(context)),
                          const SizedBox(width: 8),
                          Text(
                            '${(zone['pressure'] as double).toStringAsFixed(1)} PSI',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            'Target: 42-48 PSI',
                            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (zone['pressure'] as double) / 60.0,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                          color: isCritical
                              ? AppColors.statusCritical(context)
                              : (isLow ? AppColors.statusAttention(context) : AppColors.statusOk(context)),
                        ),
                      ),
                      if (isCritical || isLow) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCritical
                                  ? AppColors.statusCritical(context)
                                  : AppColors.statusAttention(context),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _normalizeZone(idx),
                            icon: const Icon(Icons.bolt, size: 16),
                            label: const Text('EQUALIZE PRESSURE TO 42 PSI'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }
}
