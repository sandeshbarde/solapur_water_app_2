import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthService() {
    _loadUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isLoading => _isLoading;

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userStr));
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Failed decoding cached user: $e');
      }
    }
  }

  // ── Demo accounts (used when backend is unreachable) ────────────────────
  static const Map<String, Map<String, dynamic>> _demoAccounts = {
    '9999999999': {'password': 'admin123', 'name': 'Admin Demo', 'role': 'admin', 'id': 'demo-admin-001'},
    '9000000000': {'password': 'citizen123', 'name': 'Ramesh Patil', 'role': 'citizen', 'id': 'demo-citizen-001'},
    '8888888888': {'password': 'demo1234', 'name': 'Priya Kulkarni', 'role': 'citizen', 'id': 'demo-citizen-002'},
  };

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // ── 1. Try online login ─────────────────────────────────────────────────
    try {
      final response = await ApiClient.post('/auth/login', body: {
        'phone': phone.trim(),
        'password': password.trim(),
      }, requiresAuth: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        if (token != null) {
          await ApiClient.saveToken(token);
        }

        _currentUser = UserModel(
          id: userData['id'].toString(),
          name: userData['name'] ?? 'Citizen',
          username: userData['phone'] ?? phone,
          phone: userData['phone'] ?? phone,
          role: (userData['role'] == 'admin' || userData['role'] == 'officer')
              ? UserRole.admin
              : UserRole.citizen,
          jalPoints: userData['points'] ?? 100,
          wardNumber: 4,
        );

        await _saveUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Backend returned an error (e.g. 401 wrong password) — don't fall to demo
      if (response.statusCode == 401 || response.statusCode == 400) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Network unreachable → fall through to demo mode
      if (kDebugMode) print('[AuthService] Backend unreachable: $e → trying demo mode');
    }

    // ── 2. Demo / Offline fallback ──────────────────────────────────────────
    final demo = _demoAccounts[phone.trim()];
    if (demo != null && demo['password'] == password.trim()) {
      _currentUser = UserModel(
        id: demo['id'] as String,
        name: demo['name'] as String,
        username: phone.trim(),
        phone: phone.trim(),
        role: (demo['role'] == 'admin') ? UserRole.admin : UserRole.citizen,
        jalPoints: 250,
        wardNumber: 4,
      );
      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String phone, String password, {String? email, String? ward}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/register', body: {
        'name': name.trim(),
        'phone': phone.trim(),
        'password': password.trim(),
        'email': email?.trim(),
        'ward': ward ?? 'Ward 1 (Ashok Chowk)',
      }, requiresAuth: false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        if (token != null) {
          await ApiClient.saveToken(token);
        }

        _currentUser = UserModel(
          id: userData['id'].toString(),
          name: userData['name'] ?? name,
          username: phone,
          phone: phone,
          role: UserRole.citizen,
          jalPoints: userData['points'] ?? 100,
          wardNumber: 4,
        );

        await _saveUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Online register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    } else {
      await prefs.remove('current_user');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await ApiClient.clearToken();
    await _saveUser();
    notifyListeners();
  }
}
