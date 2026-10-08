import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../services/notification_service.dart';
import '../services/sensor_stream_service.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/data_stat_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/quick_action_tile.dart';

/// Screen 12: Municipal Operational Governance Hub
/// Job: "What needs attention right now, and what can I do about it?"
class AIGovernanceDashboard extends StatefulWidget {
  const AIGovernanceDashboard({super.key});

  @override
  State<AIGovernanceDashboard> createState() => _AIGovernanceDashboardState();
}

class _AIGovernanceDashboardState extends State<AIGovernanceDashboard> {
  final TextEditingController _broadcastController = TextEditingController();

  @override
  void dispose() {
    _broadcastController.dispose();
    super.dispose();
  }

  void _verifyComplaint(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusOk(context),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Complaint verified! Citizen awarded +50 JalPoints.'),
          ],
        ),
      ),
    );
  }

  Future<void> _approveFlowBalancing() async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Approve AI Hydraulic Redistribution',
      actionDescription: 'Execute automated algorithm to modulate 6 sector valves and balance pressure across Solapur Central and East Wards.',
      consequences: [
        'Valve SV-04 angle increases from 45% to 75%.',
        'Feeder line pressure in Ward 4 increases from 28 PSI to 42 PSI.',
        'No citizen water service interruption anticipated.',
      ],
      confirmLabel: 'Approve & Execute',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: const Text('AI Hydraulic redistribution executed across 6 valves!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final complaintService = Provider.of<ComplaintService>(context);
    final complaints = complaintService.complaints;
    final pendingComplaints = complaints.where((c) => c.status == ComplaintStatus.pending).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MUNICIPAL COMMAND HUB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Hub Telemetry',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(duration: Duration(seconds: 1), content: Text('SCADA & complaints refreshed.')),
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
              final sensorData = snapshot.data ?? {'pressure': 38.5, 'tankLevel': 79.0};
              final currentPressure = (sensorData['pressure'] as num?)?.toDouble() ?? 38.5;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // 1. HERO AREA: Answer First - Critical Operational Attention
                  HeroFactCard(
                    categoryTag: 'OPERATIONAL STATUS • ACTION REQUIRED',
                    primaryFact: pendingComplaints > 0
                        ? '$pendingComplaints Citizen Tickets & 1 Pressure Imbalance'
                        : 'Grid Operational • 0 Critical Faults',
                    supportingDetail: pendingComplaints > 0
                        ? 'Ward 4 reporting low flow (28.5 PSI). AI recommends opening Valve SV-04 by 30% to equalize head.'
                        : 'All 14 municipal sectors stable. SCADA telemetry nominal.',
                    lastUpdated: 'Live sync 10s ago',
                    statusPill: StatusPill(
                      label: pendingComplaints > 0 ? 'Action Needed' : 'Normal',
                      type: pendingComplaints > 0 ? StatusType.attention : StatusType.ok,
                    ),
                    icon: Icons.shield_outlined,
                    actionButton: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: _approveFlowBalancing,
                      child: const Text('AUTO-BALANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. HARDWARE SHORTCUT TILES
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWide ? 3 : 1,
                        childAspectRatio: isWide ? 2.5 : 4.0,
                        crossAxisSpacing: AppSpacing.s12,
                        mainAxisSpacing: AppSpacing.s12,
                        children: [
                          QuickActionTile(
                            title: 'Intelligent Valve Control',
                            subtitle: 'Modulate solenoid valves',
                            icon: Icons.tune,
                            onTap: () => Navigator.pushNamed(context, '/admin_ai_control'),
                          ),
                          QuickActionTile(
                            title: 'IoT Device Manager',
                            subtitle: '48/50 nodes online',
                            icon: Icons.router_outlined,
                            onTap: () => Navigator.pushNamed(context, '/iot_devices'),
                          ),
                          QuickActionTile(
                            title: 'Pressure Regulation',
                            subtitle: 'Pump speed & thresholds',
                            icon: Icons.speed,
                            onTap: () => Navigator.pushNamed(context, '/pressure_control'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // 3. CITIZEN COMPLAINT QUEUE
                  SectionHeader(
                    title: 'PENDING CITIZEN COMPLAINTS',
                    subtitle: 'Review tickets filed with photo and GPS location',
                    trailing: Text(
                      '${complaints.length} Total',
                      style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),

                  if (complaints.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border(context), width: 1.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.statusOkDark, size: 22),
                          SizedBox(width: 12),
                          Text('No active complaints in queue. Excellent!'),
                        ],
                      ),
                    )
                  else
                    ...complaints.map((c) {
                      StatusType statusType;
                      switch (c.status) {
                        case ComplaintStatus.pending:
                          statusType = StatusType.attention;
                          break;
                        case ComplaintStatus.inProgress:
                          statusType = StatusType.info;
                          break;
                        case ComplaintStatus.resolved:
                          statusType = StatusType.ok;
                          break;
                        case ComplaintStatus.rejected:
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.report_problem_outlined, size: 18, color: accent),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ticket #${c.id} • ${c.category}',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                StatusPill(label: c.status.name.toUpperCase(), type: statusType, isCompact: true),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary(context)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    c.address,
                                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (c.status == ComplaintStatus.pending) ...[
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    onPressed: () => _verifyComplaint(c.id),
                                    child: const Text('Verify (+50 Pts)', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () => complaintService.updateStatus(c.id, 'inProgress'),
                                    child: const Text('Dispatch Crew', style: TextStyle(fontSize: 12)),
                                  ),
                                ] else if (c.status == ComplaintStatus.inProgress) ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.statusOk(context),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () => complaintService.updateStatus(c.id, 'resolved'),
                                    child: const Text('Mark Resolved', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ],
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
