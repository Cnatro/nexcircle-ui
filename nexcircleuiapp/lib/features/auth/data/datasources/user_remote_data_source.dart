import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSource({String? baseUrl})
    : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      final data = body['data'];

      if (data != null && data['accessToken'] != null) {
        final String token = data['accessToken'];

        // save token
        await AppPreferences.saveToken(token);

        // lấy user hiện tại
        final UserModel user = await getCurrentUser() as UserModel;

        await AppPreferences.saveUser(user);
        await AppPreferences.saveUserId(user.id);

        return user;
      }

      print("Login failed: ${body['message'] ?? 'Unknown error'}");
      return null;
    } catch (e) {
      print("Login exception: $e");
      return null;
    }
  }

  Future<UserModel?> register(
    String username,
    String email,
    String password,
  ) async {
    final deviceToken = await FirebaseMessaging.instance.getToken();

    if (deviceToken == null) {
      throw Exception("FCM device token is null");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'userDeviceDto': {'deviceToken': deviceToken, 'flatform': 'FLUTTER'},
      }),
    );
    // tạm thời statusCode là 200
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['data']);
    }
    print("REGISTER ERROR: ${response.body}");
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
