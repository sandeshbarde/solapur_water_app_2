import 'package:flutter/foundation.dart';

class LocationService {
  /// Simulates getting the current GPS position
  static Future<Map<String, double>> getCurrentLocation() async {
    if (kDebugMode) {
      print('Fetching GPS coordinates...');
    }
    await Future.delayed(const Duration(seconds: 2));
    
    // Mocking Solapur Coordinates
    return {
      'latitude': 17.6599,
      'longitude': 75.9064,
    };
  }

  /// Simulates reverse geocoding to get an address string
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return '123 Smart Pipeline Rd, Ward 12, Solapur, 413001';
  }
}
