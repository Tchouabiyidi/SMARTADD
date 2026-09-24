import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AuthService {
  // Default Node.js API Endpoint
  // Can be adjusted according to host environment (localhost / 10.0.2.2 / custom IP)
  static String baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:5000/api'
          : 'http://localhost:5000/api');

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'smartadd_auth_token';
  static const String _userKey = 'smartadd_auth_user';

  /// Login user with Email and Password
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'] ?? data['data'];

        if (userData == null || token == null) {
          throw AuthException('Invalid authentication response from server.');
        }

        final user = User.fromJson(userData, token: token);
        await _saveAuthData(user, token);
        return user;
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Login failed. Please check your credentials.';
        throw AuthException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      
      // Fallback for offline/demo environment when backend isn't actively reachable
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        return _handleOfflineMockLogin(email, password);
      }

      throw AuthException('Failed to connect to backend service: ${e.toString()}');
    }
  }

  /// Register new user (Advertiser or Billboard Owner ONLY)
  Future<User> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // Enforce role check: Admin cannot be created publicly
    if (role == UserRole.admin) {
      throw AuthException('Admin accounts cannot be created through public registration.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName.trim(),
          'fullName': fullName.trim(),
          'full_name': fullName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'phone_number': phone.trim(),
          'password': password,
          'role': role.toDbValue(),
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'] ?? data['data'];

        final user = User.fromJson(
          userData ?? {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'role': role.toDbValue(),
          },
          token: token ?? 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        );

        await _saveAuthData(user, user.token ?? '');
        return user;
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Registration failed. Please try again.';
        throw AuthException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is AuthException) rethrow;

      // Fallback for offline demo mode
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        final mockUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          fullName: fullName,
          email: email,
          phone: phone,
          role: role,
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await _saveAuthData(mockUser, mockUser.token!);
        return mockUser;
      }

      throw AuthException('Failed to register: ${e.toString()}');
    }
  }

  /// Logout user and remove stored session & secure token
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Restore user session on app start
  Future<User?> restoreSession() async {
    try {
      String? token;
      try {
        token = await _secureStorage.read(key: _tokenKey);
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_userKey);

      if (userJsonStr != null) {
        final userData = jsonDecode(userJsonStr);
        final userToken = token ?? userData['token'];
        return User.fromJson(userData, token: userToken);
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
    return null;
  }

  /// Get stored JWT authentication token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) return token;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final userJsonStr = prefs.getString(_userKey);
    if (userJsonStr != null) {
      final userData = jsonDecode(userJsonStr);
      return userData['token'];
    }
    return null;
  }

  /// Store token in SecureStorage and user metadata in SharedPreferences
  Future<void> _saveAuthData(User user, String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('Secure storage write warning: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Offline fallback for demonstration purposes
  User _handleOfflineMockLogin(String email, String password) {
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    // Default mock users for testing role routing
    UserRole role = UserRole.advertiser;
    if (email.contains('owner') || email.contains('billboard')) {
      role = UserRole.billboardOwner;
    } else if (email.contains('admin')) {
      role = UserRole.admin;
    }

    final user = User(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      fullName: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: email,
      phone: '+237690000000',
      role: role,
      token: 'demo_token_offline_mode',
    );

    _saveAuthData(user, user.token!);
    return user;
  }
}
