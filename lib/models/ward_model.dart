class WardModel {
  final String id;
  final String name;
  final double inequalityScore;
  final String pressureStatus; // 'normal', 'low', 'critical'
  final DateTime supplyStart;
  final DateTime supplyEnd;

  WardModel({
    required this.id,
    required this.name,
    required this.inequalityScore,
    required this.pressureStatus,
    required this.supplyStart,
    required this.supplyEnd,
  });
}
