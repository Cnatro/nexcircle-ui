import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import '../models/call_session_model.dart';

class CallRemoteDataSource {
  final String baseUrl;

  CallRemoteDataSource({String? baseUrl})
    : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';

  Future<CallSessionModel> initiateCall({
    required String receiverId,
    required String type,
  }) async {
    final token = await AppPreferences.getToken();

    if (token == null) {
      throw Exception("Token is null");
    }

    final uri = Uri.parse('$baseUrl/api/call/init');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"receiverId": receiverId, "type": type}),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      // ✅ success
      if (response.statusCode == 200 && body['data'] != null) {
        return CallSessionModel.fromJson(body['data']);
      }

      // ❌ backend trả lỗi
      throw Exception(body['message'] ?? 'Init call failed');
    } catch (e) {
      print("INIT CALL EXCEPTION: $e");
      rethrow; // đẩy lỗi lên repository
    }
  }
}
