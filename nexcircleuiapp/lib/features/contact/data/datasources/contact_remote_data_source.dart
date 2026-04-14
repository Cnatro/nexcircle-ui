import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';

class ContactRemoteDataSource {
  final String baseUrl;

  ContactRemoteDataSource({String? baseUrl})
    : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? '';

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<User>> getUsers({required int page, required int size}) async {
    final token = await AppPreferences.getToken();
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/users').replace(
      queryParameters: {'page': page.toString(), 'size': size.toString()},
    );

    final res = await http.get(uri, headers: _headers(token));

    final body = jsonDecode(res.body);
    final List data = body['data']['data'];

    return data
        .map(
          (e) => User(
            id: e['id'],
            username: e['username'],
            email: e['email'] ?? '',
          ),
        )
        .toList();
  }

  Future<List<FriendRequest>> getRequests({
    required int page,
    required int size,
  }) async {
    final token = await AppPreferences.getToken();
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/friend-requests').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'status': 'pending',
      },
    );

    final res = await http.get(uri, headers: _headers(token));

    final body = jsonDecode(res.body);
    final List data = body['data']['data'];

    return data
        .map(
          (e) => FriendRequest(
            id: e['id'],
            senderName: e['senderName'] ?? "User",
            senderId: e['senderId'],
            avatarUrl: e['senderAvatar'] ?? '',
            createdAt: e['createdAt'] != null
                ? DateTime.parse(e['createdAt'])
                : DateTime.now(),
          ),
        )
        .toList();
  }

  Future<List<Friendship>> getFriends({
    required int page,
    required int size,
  }) async {
    final token = await AppPreferences.getToken();
    if (token == null) return [];

    final uri = Uri.parse('$baseUrl/friend-ships').replace(
      queryParameters: {'page': page.toString(), 'size': size.toString()},
    );

    final res = await http.get(uri, headers: _headers(token));

    final body = jsonDecode(res.body);
    final List data = body['data']['data'];

    return data
        .map(
          (e) => Friendship(
            id: e['id'],
            fullName: e['fullName'],
            avatarUrl: e['avatar'] ?? '',
            userId: e['userId'],
          ),
        )
        .toList();
  }

  Future<void> sendFriendRequest({
    required String recieverId,
    required String status,
  }) async {
    final token = await AppPreferences.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$baseUrl/friend-requests'),
      headers: _headers(token),
      body: jsonEncode({'receiverId': recieverId, 'status': status}),
    );
  }

  Future<void> acceptRequest(String id) async {
    final token = await AppPreferences.getToken();
    if (token == null) return;

    await http.patch(
      Uri.parse('$baseUrl/friend-requests/accept'),
      headers: _headers(token),
      body: jsonEncode({'id': id, 'status': 'accepted'}),
    );
  }

  Future<void> removeFriend(String frId) async {
    final token = await AppPreferences.getToken();
    if (token == null) return;

    final res = await http.patch(
      Uri.parse('$baseUrl/friend-ships/$frId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': 'unfriended'}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to remove friend');
    }
  }

  Future<void> declineRequest(String requestId) async {
    final token = await AppPreferences.getToken();
    if (token == null) return;

    final res = await http.patch(
      Uri.parse('$baseUrl/friend-requests/decline'),
      headers: _headers(token),
      body: jsonEncode({'id': requestId, 'status': 'declined'}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to remove friend');
    }
  }
}
