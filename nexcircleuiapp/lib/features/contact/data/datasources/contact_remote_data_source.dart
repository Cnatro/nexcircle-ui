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
            senderName: e['senderName'],
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
      body: jsonEncode({'id': id, 'status': 'accepted' }),
    );
  }
}

// import 'dart:async';
// import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
// import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
// import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';

// class ContactRemoteDataSource {
//   final String baseUrl;

//   ContactRemoteDataSource({String? baseUrl}) : baseUrl = baseUrl ?? '';

//   /// 🔥 giả lập delay như gọi API
//   Future<T> _mockDelay<T>(T data) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     return data;
//   }

//   /// ================= USERS =================
//   Future<List<User>> getUsers({
//     required int page,
//     required int size,
//   }) async {
//     return _mockDelay([
//       User(id: "1", username: "Alice", email: "alice@gmail.com"),
//       User(id: "2", username: "Bob", email: "bob@gmail.com"),
//       User(id: "3", username: "Charlie", email: "charlie@gmail.com"),
//       User(id: "4", username: "David", email: "david@gmail.com"),
//       User(id: "5", username: "Emma", email: "emma@gmail.com"),
//     ]);
//   }

//   /// ================= REQUESTS =================
//   Future<List<FriendRequest>> getRequests({
//     required int page,
//     required int size,
//     required String receiverId,
//   }) async {
//     return _mockDelay([
//       FriendRequest(
//         id: "r1",
//         senderName: "John Doe",
//         senderId: "10",
//         avatarUrl: "",
//         recevierId: receiverId,
//         status: "pending",
//       ),
//       FriendRequest(
//         id: "r2",
//         senderName: "Anna Smith",
//         senderId: "11",
//         avatarUrl: "",
//         recevierId: receiverId,
//         status: "pending",
//       ),
//     ]);
//   }

//   /// ================= FRIENDS =================
//   Future<List<Friendship>> getFriends({
//     required int page,
//     required int size,
//   }) async {
//     return _mockDelay([
//       Friendship(
//         id: "f1",
//         fullName: "Michael",
//         avatarUrl: "",
//         userId: "20",
//       ),
//       Friendship(
//         id: "f2",
//         fullName: "Sophia",
//         avatarUrl: "",
//         userId: "21",
//       ),
//     ]);
//   }

//   /// ================= ACTION =================
//   Future<void> sendFriendRequest(String userId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     print("Mock: send request to $userId");
//   }

//   Future<void> acceptRequest(String id) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     print("Mock: accepted request $id");
//   }
// }
