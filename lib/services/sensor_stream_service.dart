import '../services/api_service.dart';
import 'dart:math';

class SensorStreamService {
  final ApiService _apiService = ApiService();
  
  // Shared stream so all UI listeners get the same real-time data
  late final Stream<Map<String, dynamic>> _sharedSensorStream;
  final Random _random = Random();
  
  // Storage for last known data for fuzzing during outages
  Map<String, dynamic> _lastData = {
    'pressure': 45.0, 
    'tankLevel': 65.0, 
    'flowRate': 15.5, 
    'rainfall': 0.0
  };

  SensorStreamService() {
    _sharedSensorStream = _createSensorStream().asBroadcastStream();
  }

  /// Internal generator that polls the backend
  Stream<Map<String, dynamic>> _createSensorStream() async* {
    // Initial fetch immediately
    try {
      final data = await _apiService.getSensorData();
      yield data;
    } catch (_) {}

    while (true) {
      try {
        final data = await _apiService.getSensorData();
        if (data.containsKey('error')) {
          _fuzzData();
          yield _lastData;
        } else {
          _lastData = data;
          yield data;
        }
      } catch (e) {
        _fuzzData();
        yield _lastData;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void _fuzzData() {
    // Slightly randomize last data to keep UI "alive" during connection issues
    _lastData = {
      'pressure': (_lastData['pressure'] + (_random.nextDouble() * 2 - 1)).clamp(0.0, 100.0),
      'tankLevel': (_lastData['tankLevel'] + (_random.nextDouble() * 2 - 1)).clamp(0.0, 100.0),
      'flowRate': (_lastData['flowRate'] + (_random.nextDouble() * 0.4 - 0.2)).clamp(0.0, 50.0),
      'rainfall': _lastData['rainfall'], // Usually stays constant or zero
      'is_demo': true,
    };
  }

  /// Exposed streams for the UI to consume
  Stream<double> get pressureStream => _sharedSensorStream.map((data) => (data['pressure'] as num).toDouble());
  Stream<double> get reservoirLevelStream => _sharedSensorStream.map((data) => (data['tankLevel'] as num).toDouble());
  Stream<double> get flowRateStream => _sharedSensorStream.map((data) => (data['flowRate'] as num).toDouble());
  Stream<double> get rainfallStream => _sharedSensorStream.map((data) => (data['rainfall'] as num).toDouble());
  Stream<Map<String, dynamic>> get sensorStream => _sharedSensorStream;
}
