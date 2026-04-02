class FriendRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String avatarUrl;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.senderName,
    required this.senderId,
    required this.avatarUrl,
    required this.createdAt,
  });
}
