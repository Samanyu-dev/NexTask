import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';

class AuthService {
  AuthService({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception(
        _extractError(response.body, fallback: 'Unable to register'),
      );
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, fallback: 'Login failed'));
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final token = payload['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token missing in login response');
    }

    await saveToken(token);
    return token;
  }

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  String _extractError(String body, {required String fallback}) {
    try {
      final payload = jsonDecode(body) as Map<String, dynamic>;
      return payload['detail'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
