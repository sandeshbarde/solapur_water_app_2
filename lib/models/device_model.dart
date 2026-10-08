enum DeviceType { pressureSensor, valveController }
enum DeviceStatus { active, inactive, lowPressure }

class DeviceModel {
  final String id;
  final String ward;
  final DeviceType type;
  final double latitude;
  final double longitude;
  DeviceStatus status;
  double pressure;
  double flowRate;
  DateTime? lastHeartbeat;

  DeviceModel({
    required this.id,
    required this.ward,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.status = DeviceStatus.active,
    this.pressure = 0.0,
    this.flowRate = 0.0,
    this.lastHeartbeat,
  });

  double get currentPressure => pressure;
  double get currentFlowRate => flowRate;
  int get batteryPercentage => 92;
  int get wardNumber {
    final match = RegExp(r'\d+').firstMatch(ward);
    return match != null ? int.tryParse(match.group(0)!) ?? 4 : 4;
  }

  String get typeLabel =>
      type == DeviceType.valveController ? 'Valve Controller' : 'Pressure Sensor';

  String get statusLabel {
    switch (status) {
      case DeviceStatus.active:
        return 'Active';
      case DeviceStatus.inactive:
        return 'Offline';
      case DeviceStatus.lowPressure:
        return 'Low Pressure';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ward': ward,
        'type': type.name,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.name,
        'pressure': pressure,
        'flowRate': flowRate,
      };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json['id'] ?? '',
        ward: json['ward'] ?? '',
        type: json['type'] == 'valveController'
            ? DeviceType.valveController
            : DeviceType.pressureSensor,
        latitude: (json['latitude'] ?? 17.6599).toDouble(),
        longitude: (json['longitude'] ?? 75.9064).toDouble(),
        status: DeviceStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => DeviceStatus.active,
        ),
        pressure: (json['pressure'] ?? 0.0).toDouble(),
        flowRate: (json['flowRate'] ?? 0.0).toDouble(),
      );
}
