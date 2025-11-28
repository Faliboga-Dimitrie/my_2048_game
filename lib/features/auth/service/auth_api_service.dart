// lib/features/auth/service/auth_api_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const _baseUrl = 'https://69284ac6b35b4ffc50150e1f.mockapi.io/api/v1';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['token'] as String;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<String> register({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('Register response data: $data');
      // ReqRes returns { "id": 4, "token": "..." }
      return data['token'] as String;
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }
}
