import '../../domain/entities/user.dart';

class UserModel extends User {
  final String password;
  final String fullName;
  final String avatarUrl;
  final String description;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required String id,
    required String username,
    required String email,
    required this.password,
    required this.fullName,
    required this.avatarUrl,
    required this.description,
    required this.isOnline,
    required this.lastActive,
    required this.createdAt,
    required this.updatedAt,
  }) : super(id: id, username: username, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        username: json['username'],
        email: json['email'],
        password: json['password'] ?? '',
        fullName: json['fullName'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        description: json['description'] ?? '',
        isOnline: json['isOnline'] ?? false,
        lastActive: DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
        'description': description,
        'isOnline': isOnline,
        'lastActive': lastActive.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}