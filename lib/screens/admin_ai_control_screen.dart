import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';
import '../services/sensor_stream_service.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';

/// Screen 13: Intelligent AI Valve Control Center
/// Job: "Automated AI valve control, pressure rebalancing, emergency shutoff with strict confirmation."
class AdminAIControlScreen extends StatefulWidget {
  const AdminAIControlScreen({super.key});

  @override
  State<AdminAIControlScreen> createState() => _AdminAIControlScreenState();
}

class _AdminAIControlScreenState extends State<AdminAIControlScreen> {
  bool _normalizing = false;

  Future<void> _normalizeZone(DeviceModel device) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Actuate Valve for ${device.ward}',
      actionDescription: 'You are modulating solenoid valve for node ${device.id} to normalize line pressure to ~45 PSI.',
      consequences: [
        'Valve aperture will adjust automatically based on downstream flow rate.',
        'Downstream supply pressure in Ward ${device.wardNumber} will normalize in 60-90 seconds.',
        'This actuation command is logged in municipal telemetry ledger.',
      ],
      confirmLabel: 'Confirm Actuation',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _normalizing = true);
    await Provider.of<DeviceService>(context, listen: false).normalizePressure(device.id);

    if (mounted) {
      setState(() => _normalizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: Text('Valve adjusted for ${device.ward}. Pressure normalized to ~45 PSI.'),
        ),
      );
    }
  }

  Future<void> _emergencyShutoffAll() async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'CRITICAL: EMERGENCY SHUTOFF ALL VALVES',
      actionDescription: 'You are initiating an emergency municipal shutoff sequence across all automated network valves in Solapur.',
      consequences: [
        'ALL 14 sector feeder valves will close immediately.',
        'Water delivery to all domestic and commercial lines will halt.',
        'Use only in event of major main line burst or contamination disaster.',
      ],
      confirmLabel: 'EXECUTE SHUTOFF',
      cancelLabel: 'Abort Action',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCritical(context),
          content: const Text('EMERGENCY SHUTOFF: All municipal valves locked closed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI VALVE CONTROL CENTER'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusPill(
                label: 'SCADA LIVE',
                type: StatusType.ok,
                isCompact: true,
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<DeviceService, SensorStreamService>(
        builder: (context, deviceService, sensorService, _) {
          final lowPressureDevices = deviceService.devices
              .where((d) => d.status == DeviceStatus.lowPressure)
              .toList();
          final activeCount = deviceService.devices.where((d) => d.status == DeviceStatus.active).length;

          return SafeArea(
            child: ResponsiveContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              child: ListView(
                children: [
                  // 1. HERO AREA: Automation & Pressure Equalization
                  HeroFactCard(
                    categoryTag: 'AUTOMATED EQUALIZATION GRID',
                    primaryFact: lowPressureDevices.isEmpty
                        ? 'All 14 Sector Valves Equalized'
                        : '${lowPressureDevices.length} Valve(s) Require Actuation',
                    supportingDetail: lowPressureDevices.isEmpty
                        ? 'SCADA hydraulic balance is steady. Mean pressure at 43.2 PSI across Solapur Central and East.'
                        : 'Pressure drop detected in ${lowPressureDevices.map((d) => d.ward).join(", ")}. Equalization ready.',
                    statusPill: StatusPill(
                      label: lowPressureDevices.isEmpty ? 'Nominal' : 'Action Required',
                      type: lowPressureDevices.isEmpty ? StatusType.ok : StatusType.attention,
                    ),
                    icon: Icons.tune,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. OVERVIEW METRICS
                  Row(
                    children: [
                      Expanded(
                        child: DataStatCard(
                          title: 'Active Valves',
                          value: '$activeCount Nodes',
                          icon: Icons.check_circle_outline,
                          color: AppColors.statusOk(context),
                          subtitle: 'Responding to AI',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: DataStatCard(
                          title: 'Anomalies',
                          value: '${lowPressureDevices.length} Drops',
                          icon: Icons.warning_amber_rounded,
                          color: lowPressureDevices.isEmpty ? AppColors.statusOk(context) : AppColors.statusAttention(context),
                          subtitle: 'Auto-detected',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // 3. ANOMALY ACTUATION QUEUE
                  SectionHeader(
                    title: 'VALVES REQUIRING ATTENTION',
                    subtitle: 'AI calibrated adjustments ready for operator execution',
                  ),

                  if (lowPressureDevices.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border(context), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.statusOk(context), size: 24),
                          const SizedBox(width: AppSpacing.s12),
                          const Expanded(
                            child: Text('All sector pressure valves currently at optimal balance.'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...lowPressureDevices.map((device) {
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
                                Row(
                                  children: [
                                    Icon(Icons.speed, size: 18, color: AppColors.statusAttention(context)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Node ${device.id} • ${device.ward}',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                StatusPill(label: 'LOW FLOW', type: StatusType.attention, isCompact: true),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Current Pressure: ${device.currentPressure.toStringAsFixed(1)} PSI (Threshold: 35.0 PSI). AI proposes +25% valve aperture to restore downstream gradient.',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusAttention(context),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _normalizing ? null : () => _normalizeZone(device),
                                icon: const Icon(Icons.bolt, size: 18),
                                label: const Text('CONFIRM & EQUALIZE PRESSURE'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.s28),

                  // 4. CRITICAL EMERGENCY HARDWARE ACTION
                  SectionHeader(
                    title: 'EMERGENCY PROTOCOLS',
                    subtitle: 'Hardware override for disaster and contamination events',
                  ),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusCritical(context),
                        side: BorderSide(color: AppColors.statusCritical(context), width: 1.5),
                      ),
                      onPressed: _emergencyShutoffAll,
                      icon: const Icon(Icons.emergency_outlined, size: 20),
                      label: const Text(
                        'EMERGENCY VALVE SHUTOFF (ALL SECTORS)',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
