import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/device_model.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';

/// Screen 15: Municipal IoT Device Manager
/// Job: "Fleet management of flowmeters, pressure sensors, and RTUs across Solapur."
class IoTDeviceManagerScreen extends StatefulWidget {
  const IoTDeviceManagerScreen({super.key});

  @override
  State<IoTDeviceManagerScreen> createState() => _IoTDeviceManagerScreenState();
}

class _IoTDeviceManagerScreenState extends State<IoTDeviceManagerScreen> {
  final _nodeIdController = TextEditingController();
  final _coordController = TextEditingController();
  String _selectedWard = 'Indira Nagar';
  String _selectedType = 'Pressure Sensor';
  bool _isActive = true;
  bool _formExpanded = false;
  bool _isSaving = false;

  final List<String> _wards = [
    'Indira Nagar',
    'Gandhi Ward',
    'Civil Lines',
    'Shivaji Nagar',
    'Ward 7 West',
    'Ward 12 North',
  ];

  @override
  void dispose() {
    _nodeIdController.dispose();
    _coordController.dispose();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    if (_nodeIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an IoT Node ID')),
      );
      return;
    }

    final coords = _coordController.text.split(',');
    double lat = 17.6599;
    double lon = 75.9064;
    if (coords.length == 2) {
      lat = double.tryParse(coords[0].trim()) ?? lat;
      lon = double.tryParse(coords[1].trim()) ?? lon;
    }

    setState(() => _isSaving = true);

    final device = DeviceModel(
      id: _nodeIdController.text.trim(),
      ward: _selectedWard,
      type: _selectedType == 'Valve Controller' ? DeviceType.valveController : DeviceType.pressureSensor,
      latitude: lat,
      longitude: lon,
      status: _isActive ? DeviceStatus.active : DeviceStatus.inactive,
      pressure: 45.0,
    );

    await Provider.of<DeviceService>(context, listen: false).addDevice(device);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _formExpanded = false;
        _nodeIdController.clear();
        _coordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: Text('IoT Hardware Node ${device.id} provisioned into Solapur grid.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteDevice(DeviceModel device) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'De-register IoT Node ${device.id}',
      actionDescription: 'You are removing this telemetry hardware from active SCADA monitoring.',
      consequences: [
        'Live stream packets from this unit will be ignored.',
        'Historical calibration logs will be archived.',
      ],
      confirmLabel: 'De-register',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await Provider.of<DeviceService>(context, listen: false).deleteDevice(device.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: Text('Node ${device.id} removed from fleet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = Provider.of<AuthService>(context).isAdmin;
    final deviceService = Provider.of<DeviceService>(context);
    final devices = deviceService.devices;
    final activeCount = devices.where((d) => d.status == DeviceStatus.active).length;
    final accent = AppColors.accent(context);

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 56, color: AppColors.statusCritical(context)),
              const SizedBox(height: 16),
              const Text('Admin Access Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('GO BACK')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('IOT FLEET MANAGER'),
        actions: [
          IconButton(
            icon: Icon(_formExpanded ? Icons.close : Icons.add),
            tooltip: _formExpanded ? 'Close Form' : 'Add IoT Node',
            onPressed: () => setState(() => _formExpanded = !_formExpanded),
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Fleet Health
              HeroFactCard(
                categoryTag: 'MUNICIPAL TELEMETRY FLEET',
                primaryFact: '$activeCount/${devices.length} Nodes Online • 96% Health',
                supportingDetail: 'Continuous RTU telemetry monitoring pipeline pressure, flow rate, and valve position across 6 municipal wards.',
                statusPill: const StatusPill(label: 'Fleet Healthy', type: StatusType.ok),
                icon: Icons.router_outlined,
              ),
              const SizedBox(height: AppSpacing.s16),

              // 2. PROVISIONING FORM (Collapsible)
              if (_formExpanded) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provision New IoT Hardware Node',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      TextFormField(
                        controller: _nodeIdController,
                        decoration: const InputDecoration(
                          labelText: 'Node Identifier',
                          hintText: 'e.g. SN-W04-PRS-02',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      DropdownButtonFormField<String>(
                        value: _selectedWard,
                        items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedWard = val);
                        },
                        decoration: const InputDecoration(labelText: 'Assigned Ward'),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: ['Pressure Sensor', 'Valve Controller', 'Flow Meter']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                        decoration: const InputDecoration(labelText: 'Device Type'),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      TextFormField(
                        controller: _coordController,
                        decoration: const InputDecoration(
                          labelText: 'Coordinates (Lat, Lon)',
                          hintText: 'e.g. 17.6599, 75.9064',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _registerDevice,
                          child: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('PROVISION HARDWARE NODE'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
              ],

              // 3. REGISTERED NODES LIST
              SectionHeader(
                title: 'DEPLOYED SENSOR & VALVE NODES',
                subtitle: 'Active LoRaWAN / Cellular RTUs transmitting live packets',
              ),
              ...devices.map((device) {
                StatusType statusType = StatusType.ok;
                if (device.status == DeviceStatus.lowPressure) statusType = StatusType.attention;
                if (device.status == DeviceStatus.inactive) statusType = StatusType.critical;

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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        child: Icon(Icons.sensors, color: accent, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  device.id,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                StatusPill(label: device.status.name.toUpperCase(), type: statusType, isCompact: true),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${device.ward} • ${device.type.name} • ${device.currentPressure.toStringAsFixed(1)} PSI • Batt: ${device.batteryPercentage}%',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: AppColors.statusCritical(context)),
                        tooltip: 'De-register node',
                        onPressed: () => _confirmDeleteDevice(device),
                      ),
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
