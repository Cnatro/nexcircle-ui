class User {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final bool? isOnline;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.isOnline,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "fullName": fullName,
      "avatarUrl": avatarUrl,
      "isOnline": isOnline,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      fullName: json["fullName"],
      avatarUrl: json["avatarUrl"],
      isOnline: json["isOnline"] ?? false,
    );
  }
}
