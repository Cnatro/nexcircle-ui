import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSource({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';

  Future<UserModel?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      await AppPreferences.saveToken(
        jsonDecode(response.body)['data']['accessToken'],
      );
      return getCurrentUser();
    }
    return null;
  }

  Future<UserModel?> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    // tạm thời statusCode là 200
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['data']);
    }
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await AppPreferences.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['data']);
    }
    return null;
  }
}
