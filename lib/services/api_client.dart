import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String _defaultUrl = 'http://10.0.2.2:5000'; // Standard Android Emulator to host loopback
  static const String baseUrl = String.fromEnvironment('BACKEND_BASE_URL', defaultValue: _defaultUrl);

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static String? _cachedToken;

  static Future<String?> getToken() async {
    _cachedToken ??= await _storage.read(key: 'jwt_token');
    return _cachedToken;
  }

  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> get(String endpoint, {bool requiresAuth = true, int retries = 2}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    int attempt = 0;
    while (attempt <= retries) {
      try {
        final headers = await _getHeaders(requiresAuth: requiresAuth);
        final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
        return response;
      } catch (e) {
        attempt++;
        if (attempt > retries) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
    throw Exception('Failed request after $retries retries');
  }

  static Future<http.Response> post(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final jsonBody = body != null ? jsonEncode(body) : null;
    return await http.post(uri, headers: headers, body: jsonBody).timeout(const Duration(seconds: 15));
  }

  static Future<http.Response> patch(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final jsonBody = body != null ? jsonEncode(body) : null;
    return await http.patch(uri, headers: headers, body: jsonBody).timeout(const Duration(seconds: 15));
  }

  static Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<File>? files,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    fields.forEach((k, v) {
      request.fields[k] = v;
    });

    if (files != null) {
      for (var f in files) {
        if (await f.exists()) {
          final multipartFile = await http.MultipartFile.fromPath('files', f.path);
          request.files.add(multipartFile);
        }
      }
    }

    return await request.send().timeout(const Duration(seconds: 30));
  }
}
