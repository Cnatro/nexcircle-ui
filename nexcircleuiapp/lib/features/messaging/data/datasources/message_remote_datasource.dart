import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/messaging/data/models/message_model.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/attachment.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message_receipt.dart';
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

  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required int page,
    required int size,
  }) async {
    final token = await AppPreferences.getToken();

    final uri = Uri.parse('$baseUrl/messages').replace(
      queryParameters: {
        'conversationId': conversationId,
        'page': '$page',
        'size': '$size',
      },
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load messages');
    }

    final data = jsonDecode(res.body);
    final list = data['data']['data'] as List;

    return list.map((e) {
      final senderJson = e['sender'];

      return MessageModel(
        id: e['id'],
        content: e['content'] ?? '',
        createdAt: e['createdAt'] != null
            ? DateTime.parse(e['createdAt'])
            : DateTime.now(), // fallback nhẹ

        sender: senderJson != null
            ? User(
                id: senderJson['id'] ?? '',
                fullName: senderJson['fullName'] ?? '',
                username: senderJson['username'] ?? '',
                avatarUrl: senderJson['avatarUrl'],
                isOnline: senderJson['isOnline'] ?? false,
                email: senderJson['email'] ?? '',
              )
            : User(
                id: '',
                fullName: '',
                username: '',
                avatarUrl: null,
                isOnline: false,
                email: '',
              ),

        attachments: (e['attachments'] as List? ?? [])
            .map(
              (a) => Attachment(
                id: a['id'],
                fileUrl: a['fileUrl'],
                fileType: a['fileType'],
                fileSize: a['fileSize'],
              ),
            )
            .toList(),

        messageReceipts: (e['messageReceipts'] as List? ?? [])
            .map(
              (r) => MessageReceipt(
                id: r['id'],
                readAt: r['readAt'] != null
                    ? DateTime.parse(r['readAt'])
                    : null, //
              ),
            )
            .toList(),
      );
    }).toList();
  }
}
