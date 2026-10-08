import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/config/map_config.dart';
import '../l10n/app_localizations.dart';
import '../models/device_model.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../widgets/status_pill.dart';
import '../widgets/hero_fact_card.dart';

/// Screen 3: Smart Water Network Map
/// Job: "Inspect water supply zones, network status, alerts, and live water delivery status on the map."
class SmartWaterMap extends StatefulWidget {
  const SmartWaterMap({super.key});

  @override
  State<SmartWaterMap> createState() => _SmartWaterMapState();
}

class _SmartWaterMapState extends State<SmartWaterMap> {
  final MapController _mapController = MapController();
  bool _showPipelines = true;
  bool _showESR = true;
  bool _showZones = true;
  bool _showPressureLayer = false;
  bool _showDeviceMarkers = true;
  String? _selectedWard;
  String _mapLayer = 'Infrastructure';

  void _onWardTap(String name, String status, StatusType statusType) {
    setState(() {
      _selectedWard = name;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(AppSpacing.s12),
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border(context), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusPill(label: status, type: statusType),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStat('Grid Health', '96%', Icons.health_and_safety_outlined),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _buildDetailStat('Last Delivery', '2h ago', Icons.schedule),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _buildDetailStat('Pressure', '41.5 PSI', Icons.speed),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/report_issue');
                  },
                  icon: const Icon(Icons.report_problem_outlined, size: 18),
                  label: const Text('REPORT ISSUE IN THIS ZONE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.accent(context)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showDevicePopup(BuildContext context, DeviceModel device, bool isAdmin, StatusType statusType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppSpacing.s12),
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border(context), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEVICE ${device.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Type: ${device.type.name.toUpperCase()} • Ward ${device.wardNumber}',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
                StatusPill(
                  label: device.status.name.toUpperCase(),
                  type: statusType,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Battery', style: TextStyle(fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${device.batteryPercentage}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Pressure', style: TextStyle(fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${device.currentPressure.toStringAsFixed(1)} PSI', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Flow Rate', style: TextStyle(fontSize: 11)),
                      const SizedBox(height: 2),
                      Text('${device.currentFlowRate.toStringAsFixed(1)} L/m', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (isAdmin)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/pressure_control');
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('CALIBRATE / CONTROL SENSOR'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final deviceService = Provider.of<DeviceService>(context);
    final isAdmin = authService.isAdmin;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Interactive Flutter Map with High-Contrast Layers
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(17.6599, 75.9064), // Solapur city centre
              initialZoom: 13.0,  // Shows the full city at a glance
              minZoom: 10.0,
              maxZoom: 20.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: isDark ? MapConfig.darkTileUrl : MapConfig.lightTileUrl,
                subdomains: MapConfig.freeSubdomains,
                userAgentPackageName: 'com.solapur.water_app',
                maxZoom: 20,
              ),

              // Water Zones (Solid translucent fills + clear borders)
              if (_showZones)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: const [
                        LatLng(17.65, 75.90), LatLng(17.67, 75.90), LatLng(17.67, 75.92), LatLng(17.65, 75.92),
                      ],
                      color: _showPressureLayer
                          ? AppColors.statusOkDark.withOpacity(0.2)
                          : AppColors.accentDark.withOpacity(0.12),
                      borderStrokeWidth: 1.5,
                      borderColor: accent,
                      isFilled: true,
                    ),
                    Polygon(
                      points: const [
                        LatLng(17.65, 75.89), LatLng(17.66, 75.90), LatLng(17.65, 75.91), LatLng(17.64, 75.90),
                      ],
                      color: _showPressureLayer
                          ? AppColors.statusAttentionDark.withOpacity(0.2)
                          : AppColors.accentLight.withOpacity(0.12),
                      borderStrokeWidth: 1.5,
                      borderColor: AppColors.statusAttention(context),
                      isFilled: true,
                    ),
                  ],
                ),

              // Pipelines (Clean solid lines, no neon animation)
              if (_showPipelines)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: const [LatLng(17.6599, 75.9064), LatLng(17.6650, 75.9150), LatLng(17.6750, 75.9250)],
                      strokeWidth: 3.5,
                      color: accent,
                    ),
                    Polyline(
                      points: const [LatLng(17.6599, 75.9064), LatLng(17.6550, 75.8950), LatLng(17.6450, 75.8850)],
                      strokeWidth: 3.5,
                      color: accent.withOpacity(0.85),
                    ),
                  ],
                ),

              // Smart Devices
              if (_showDeviceMarkers)
                MarkerLayer(
                  markers: deviceService.devices.map((device) {
                    StatusType statusType;
                    Color markerColor;
                    switch (device.status) {
                      case DeviceStatus.active:
                        statusType = StatusType.ok;
                        markerColor = AppColors.statusOk(context);
                        break;
                      case DeviceStatus.lowPressure:
                        statusType = StatusType.attention;
                        markerColor = AppColors.statusAttention(context);
                        break;
                      case DeviceStatus.inactive:
                        statusType = StatusType.critical;
                        markerColor = AppColors.statusCritical(context);
                        break;
                    }

                    return Marker(
                      point: LatLng(device.latitude, device.longitude),
                      width: 48,
                      height: 48,
                      child: Semantics(
                        button: true,
                        label: 'Device ${device.id}, status ${device.status.name}',
                        child: GestureDetector(
                          onTap: () => _showDevicePopup(context, device, isAdmin, statusType),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.0),
                                ),
                                child: Icon(
                                  device.status == DeviceStatus.lowPressure
                                      ? Icons.priority_high
                                      : Icons.sensors,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.surface(context),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border(context), width: 0.5),
                                ),
                                child: Text(
                                  device.id,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // Reservoirs / ESR Markers
              if (_showESR)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(17.6650, 75.9150),
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () => _onWardTap("ESR North Solapur", "OPTIMAL", StatusType.ok),
                        child: _buildStationMarker("ESR-1", Icons.water_drop, AppColors.statusOk(context)),
                      ),
                    ),
                    Marker(
                      point: const LatLng(17.6550, 75.8950),
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () => _onWardTap("Main WTP Solapur", "OPERATIONAL", StatusType.info),
                        child: _buildStationMarker("WTP", Icons.factory_outlined, accent),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Answer First Hero: Top Network Status
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        child: Icon(Icons.hub_outlined, color: accent, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isAdmin ? 'MUNICIPAL INFRASTRUCTURE GRID' : 'SOLAPUR WATER NETWORK',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              _selectedWard ?? 'Central Grid: Flow Active',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const StatusPill(label: 'Normal', type: StatusType.ok, isCompact: true),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Map Layer Control Tools (Thumb reachable right side)
          Positioned(
            right: 16,
            top: 110,
            child: Column(
              children: [
                _buildToolButton(
                  icon: Icons.my_location,
                  isActive: false,
                  tooltip: 'Recenter on Solapur',
                  onTap: () => _mapController.move(
                    const LatLng(MapConfig.solapurLat, MapConfig.solapurLng),
                    MapConfig.defaultZoom,
                  ),
                ),
                const SizedBox(height: 8),
                _buildToolButton(
                  icon: Icons.layers_outlined,
                  isActive: _showZones,
                  tooltip: 'Toggle Zones',
                  onTap: () => setState(() => _showZones = !_showZones),
                ),
                const SizedBox(height: 8),
                _buildToolButton(
                  icon: Icons.water_damage_outlined,
                  isActive: _showPipelines,
                  tooltip: 'Toggle Pipelines',
                  onTap: () => setState(() => _showPipelines = !_showPipelines),
                ),
                const SizedBox(height: 8),
                _buildToolButton(
                  icon: Icons.storage_outlined,
                  isActive: _showESR,
                  tooltip: 'Toggle Reservoirs',
                  onTap: () => setState(() => _showESR = !_showESR),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  _buildToolButton(
                    icon: Icons.speed,
                    isActive: _showPressureLayer,
                    tooltip: 'Toggle Pressure Heatmap',
                    onTap: () => setState(() => _showPressureLayer = !_showPressureLayer),
                  ),
                ],
              ],
            ),
          ),

          // 4. Map Legend (Bottom left, solid surface)
          Positioned(
            left: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.control),
                border: Border.all(color: AppColors.border(context), width: 1.0),
              ),
              child: Row(
                children: [
                  _legendItem(accent, 'Pipeline'),
                  const SizedBox(width: 12),
                  _legendItem(AppColors.statusOk(context), 'Optimal'),
                  const SizedBox(width: 12),
                  _legendItem(AppColors.statusAttention(context), 'Low Press.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationMarker(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.0),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final accent = AppColors.accent(context);
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? accent.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.15)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.control),
                border: Border.all(
                  color: isActive ? accent : AppColors.border(context),
                  width: isActive ? 1.5 : 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? accent : AppColors.textSecondary(context),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
