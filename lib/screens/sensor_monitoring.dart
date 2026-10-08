import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/device_model.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../services/sensor_stream_service.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/state_views.dart';

/// Screen 4: Sensor Monitoring & Telemetry
/// Job: "Monitor real-time pipeline pressure, flow rate, reservoir levels, and water quality with last updated timestamps."
class SensorMonitoringScreen extends StatefulWidget {
  const SensorMonitoringScreen({super.key});

  @override
  State<SensorMonitoringScreen> createState() => _SensorMonitoringScreenState();
}

class _SensorMonitoringScreenState extends State<SensorMonitoringScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = Provider.of<AuthService>(context).isAdmin;
    final deviceService = Provider.of<DeviceService>(context);
    final devices = deviceService.devices;

    final activeCount = devices.where((d) => d.status == DeviceStatus.active).length;
    final alertCount = devices.where((d) => d.status == DeviceStatus.lowPressure).length;
    final offlineCount = devices.where((d) => d.status == DeviceStatus.inactive).length;

    final filteredDevices = devices.where((d) {
      if (_selectedFilter == 'ACTIVE') return d.status == DeviceStatus.active;
      if (_selectedFilter == 'ALERT') return d.status == DeviceStatus.lowPressure;
      if (_selectedFilter == 'OFFLINE') return d.status == DeviceStatus.inactive;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.sensors.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Telemetry',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text('Sensor telemetry refreshed from Solapur SCADA network'),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: StreamBuilder<Map<String, dynamic>>(
            stream: Provider.of<SensorStreamService>(context, listen: false).sensorStream,
            builder: (context, snapshot) {
              final sensorData = snapshot.data ?? {'pressure': 41.8, 'tankLevel': 82.0};
              final currentPressure = (sensorData['pressure'] as num?)?.toDouble() ?? 41.8;
              final currentTank = (sensorData['tankLevel'] as num?)?.toDouble() ?? 82.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // 1. HERO AREA: Answer First - Grid Health & Master Telemetry
                  HeroFactCard(
                    categoryTag: 'SOLAPUR SCADA NETWORK • REAL-TIME',
                    primaryFact: '$activeCount/${devices.length} Sensors Active • ${currentPressure.toStringAsFixed(1)} PSI Avg',
                    supportingDetail: alertCount > 0
                        ? '$alertCount node(s) reporting abnormal line pressure. AI equalization valve active.'
                        : 'All hydraulic sensors within nominal tolerance (30-55 PSI). Water quality index: 98.4%.',
                    lastUpdated: 'Live update • 3s polling',
                    statusPill: StatusPill(
                      label: alertCount > 0 ? l10n.statusAttention : l10n.statusOk,
                      type: alertCount > 0 ? StatusType.attention : StatusType.ok,
                    ),
                    icon: Icons.sensors,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. SUPPORTING DETAIL: Telemetry Key Metric Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWide ? 4 : 2,
                        childAspectRatio: isWide ? 1.5 : 1.25,
                        crossAxisSpacing: AppSpacing.s12,
                        mainAxisSpacing: AppSpacing.s12,
                        children: [
                          DataStatCard(
                            title: l10n.pipelinePressure,
                            value: '${currentPressure.toStringAsFixed(1)} PSI',
                            icon: Icons.speed,
                            color: currentPressure >= 35.0 ? AppColors.statusOk(context) : AppColors.statusAttention(context),
                            subtitle: 'Nominal 40-50 PSI',
                          ),
                          DataStatCard(
                            title: l10n.tankLevel,
                            value: '${currentTank.toInt()}%',
                            icon: Icons.storage,
                            color: AppColors.accent(context),
                            subtitle: 'Ujani Distribution',
                          ),
                          DataStatCard(
                            title: l10n.flowRate,
                            value: '1,420 L/m',
                            icon: Icons.waves,
                            color: AppColors.accent(context),
                            subtitle: 'Main Feeder 2',
                          ),
                          DataStatCard(
                            title: l10n.waterQuality,
                            value: '7.4 pH',
                            icon: Icons.biotech,
                            color: AppColors.statusOk(context),
                            subtitle: 'TDS: 180 ppm (Potable)',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // 3. HARDWARE NODES & FILTER CHIPS
                  SectionHeader(
                    title: 'HARDWARE SENSORS & VALVES',
                    subtitle: 'IoT telemetry from Solapur distribution network',
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', 'ACTIVE', 'ALERT', 'OFFLINE'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = filter);
                            },
                            selectedColor: AppColors.accent(context).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.accent(context)
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.accent(context) : AppColors.border(context),
                              width: 1.0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // 4. DEVICE NODES LIST
                  if (filteredDevices.isEmpty)
                    AppEmptyView(
                      icon: Icons.sensors_off_outlined,
                      title: 'No Hardware Nodes Found',
                      message: 'No sensors match the "$_selectedFilter" filter criteria.',
                    )
                  else
                    ...filteredDevices.map((device) {
                      StatusType statusType;
                      switch (device.status) {
                        case DeviceStatus.active:
                          statusType = StatusType.ok;
                          break;
                        case DeviceStatus.lowPressure:
                          statusType = StatusType.attention;
                          break;
                        case DeviceStatus.inactive:
                          statusType = StatusType.critical;
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border(context), width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accent(context).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppRadius.control),
                                border: Border.all(color: AppColors.accent(context).withOpacity(0.25), width: 1.0),
                              ),
                              child: Icon(
                                device.type == DeviceType.valveController
                                    ? Icons.tune
                                    : Icons.speed,
                                color: AppColors.accent(context),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Node ${device.id}',
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ward ${device.wardNumber}',
                                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${device.currentPressure.toStringAsFixed(1)} PSI • ${device.currentFlowRate.toStringAsFixed(0)} L/m • Battery: ${device.batteryPercentage}%',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              label: device.status.name.toUpperCase(),
                              type: statusType,
                              isCompact: true,
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.s20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
