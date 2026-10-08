enum SensorType { pressure, flow, tankLevel }
enum SensorStatus { normal, low, critical }

class SensorModel {
  final String id;
  final String location;
  final SensorType type;
  final double latestReading;
  final String unit;
  final DateTime lastUpdated;
  final SensorStatus status;

  SensorModel({
    required this.id,
    required this.location,
    required this.type,
    required this.latestReading,
    required this.unit,
    required this.lastUpdated,
    required this.status,
  });
}
