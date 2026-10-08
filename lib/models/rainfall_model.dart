class RainfallModel {
  final String id;
  final DateTime date;
  final double amountMm;
  final String intensity; // 'light', 'moderate', 'heavy'
  final double probability;

  RainfallModel({
    required this.id,
    required this.date,
    required this.amountMm,
    required this.intensity,
    required this.probability,
  });
}
