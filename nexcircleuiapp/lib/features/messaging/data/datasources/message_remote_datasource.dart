import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/participant.dart';

class MessageRemoteDataSource {
  final String baseUrl;

  MessageRemoteDataSource({String? baseUrl})
    : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<Conversation>> getConversations({
    required int page,
    required int size,
  }) async {
    final token = await AppPreferences.getToken();
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/conversations').replace(
      queryParameters: {'page': page.toString(), 'size': size.toString()},
    );

    final res = await http.get(uri, headers: _headers(token));

    final body = jsonDecode(res.body);

    final List data = body['data'];

    return data.map((e) {
      return Conversation(
        id: e['id'],
        type: e['type'],
        name: e['name'],
        avatar: e['avatar'],
        participants: (e['participants'] as List)
            .map(
              (p) => Participant(
                id: p['id'],
                userId: p['userId'],
                fullName: p['fullName'],
                userName: p['userName'],
                avatarUrl: p['avatarUrl'],
                isOnline: p['isOnline'] ?? false,
              ),
            )
            .toList(),
        lastMessage: null, // map sau nếu cần
        unreadCount: e['unreadCount'] ?? 0,
        mute: e['mute'] ?? false,
      );
    }).toList();
  }

  Future<Conversation> createConversation({
    required List<String> userIds,
    required String type,
    required String name,
  }) async {
    final token = await AppPreferences.getToken();
    if (token == null) throw Exception("Unauthorized");

    final res = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: _headers(token),
      body: jsonEncode({"userIds": userIds, "type": type, "name": name}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to create conversation");
    }

    final body = jsonDecode(res.body);
    final data = body['data'];

    return Conversation(
      id: data['id'] ?? "",
      type: data['type'] ?? "",
      name: data['name'] ?? "",
      avatar: data['avatar'] ?? "",
      participants: [],
      lastMessage: null,
      unreadCount: 0,
      mute: false,
    );
  }
}
