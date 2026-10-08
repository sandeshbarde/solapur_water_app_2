import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';

class DeviceService extends ChangeNotifier {
  final List<DeviceModel> _devices = [];
  Timer? _refreshTimer;
  bool _isLoading = false;
  final Random _random = Random();

  List<DeviceModel> get devices => List.unmodifiable(_devices);
  bool get isLoading => _isLoading;

  DeviceService() {
    _seedDefaultDevices();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _simulateLiveUpdates();
    });
  }

  // Seed demo devices on startup
  void _seedDefaultDevices() {
    _devices.addAll([
      DeviceModel(
        id: 'SN-102',
        ward: 'Indira Nagar – Sector 4',
        type: DeviceType.pressureSensor,
        latitude: 17.6650,
        longitude: 75.9150,
        status: DeviceStatus.active,
        pressure: 42.0,
        flowRate: 15.5,
      ),
      DeviceModel(
        id: 'VC-049',
        ward: 'Civil Lines – Tank A',
        type: DeviceType.valveController,
        latitude: 17.6550,
        longitude: 75.8950,
        status: DeviceStatus.active,
        pressure: 55.0,
        flowRate: 60.0,
      ),
      DeviceModel(
        id: 'SEN-4592',
        ward: 'Shivaji Nagar',
        type: DeviceType.pressureSensor,
        latitude: 17.6600,
        longitude: 75.9100,
        status: DeviceStatus.lowPressure,
        pressure: 18.5,
        flowRate: 22.0,
      ),
      DeviceModel(
        id: 'SN-088',
        ward: 'Gandhi Ward – Outlet 2',
        type: DeviceType.pressureSensor,
        latitude: 17.6700,
        longitude: 75.9050,
        status: DeviceStatus.inactive,
        pressure: 0.0,
        flowRate: 0.0,
      ),
    ]);
  }

  // Slightly fuzz live pressure/flow values to simulate real-time data
  void _simulateLiveUpdates() {
    bool changed = false;
    for (final device in _devices) {
      if (device.status == DeviceStatus.active) {
        device.pressure = (device.pressure + (_random.nextDouble() * 2 - 1)).clamp(0.0, 100.0);
        device.flowRate = (device.flowRate + (_random.nextDouble() * 0.4 - 0.2)).clamp(0.0, 100.0);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // Add a new device (local + attempt cloud POST)
  Future<bool> addDevice(DeviceModel device) async {
    _devices.insert(0, device);
    notifyListeners();

    try {
      final url = Uri.parse('https://dweet.io/dweet/for/jalnirnay-devices');
      await http.get(
        Uri.parse('${url.toString()}?action=add&id=${device.id}&ward=${Uri.encodeComponent(device.ward)}&type=${device.type.name}&lat=${device.latitude}&lon=${device.longitude}'),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) print('Device cloud sync failed: $e');
    }
    return true;
  }

  // Normalize pressure for a specific device
  Future<void> normalizePressure(String deviceId) async {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx == -1) return;

    _devices[idx].pressure = 45.0 + (_random.nextDouble() * 10);
    _devices[idx].status = DeviceStatus.active;
    notifyListeners();

    try {
      await http.get(
        Uri.parse('https://dweet.io/dweet/for/jalnirnay-valve-control?valveId=$deviceId&action=INCREASE_PRESSURE'),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) print('Valve control cloud call failed: $e');
    }
  }

  // Toggle valve device open/close/auto
  void toggleValve(String deviceId, String mode) {
    if (kDebugMode) print('Valve $deviceId set to $mode');
  }

  // Remove a device from the list
  Future<void> deleteDevice(String deviceId) async {
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
