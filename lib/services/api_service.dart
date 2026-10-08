import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {

  // UNIQUE CLOUD ENDPOINT (HTTPS is safer against ISP injection)
  static const String thingName = "solapur-water-ai-v2-stable";
  static const String baseUrl = "https://dweet.io";

  Future<Map<String, dynamic>> getSensorData({int retries = 3}) async {
    final url = Uri.parse("$baseUrl/get/latest/dweet/for/$thingName");
    
    int attempt = 0;
    while (attempt < retries) {
      try {
        if (kDebugMode && attempt == 0) print("Fetching live sensors from dweet.io...");
        
        final response = await http.get(
          url,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 && response.body.trim().startsWith('{')) {
          final jsonData = jsonDecode(response.body);
          if (jsonData["this"] == "succeeded" && (jsonData["with"] as List).isNotEmpty) {
            final content = jsonData["with"][0]["content"];
            return {
              "pressure": (content["p"] ?? 0.0).toDouble(),
              "tankLevel": (content["t"] ?? 0.0).toDouble(),
              "flowRate": (content["f"] ?? 0.0).toDouble(),
              "rainfall": (content["r"] ?? 0.0).toDouble(),
            };
          }
        } else if (kDebugMode) {
          print("Invalid response format or status: ${response.statusCode}");
          if (response.body.length > 100) {
            print("Body snippet: ${response.body.substring(0, 50)}...");
          }
        }
      } catch (e) {
        attempt++;
        if (kDebugMode) print("API Attempt $attempt failed: $e");
        if (attempt >= retries) break;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    // Fallback values
    return {
      "pressure": 0.0,
      "tankLevel": 0.0,
      "rainfall": 0.0,
      "flowRate": 0.0,
      "error": "Failed after $retries attempts"
    };
  }
}