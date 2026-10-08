class PipelineModel {
  final String id;
  final String startNodeId;
  final String endNodeId;
  final double currentPressure;
  final double maxPressure;
  final bool isBurstRisk;
  final double flowRate;

  PipelineModel({
    required this.id,
    required this.startNodeId,
    required this.endNodeId,
    required this.currentPressure,
    required this.maxPressure,
    required this.isBurstRisk,
    required this.flowRate,
  });
}
