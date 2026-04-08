class Participant {
  final String id;
  final String userId;
  final String fullName;
  final String userName;
  final String? avatarUrl;
  final bool isOnline;

  Participant({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.userName,
    this.avatarUrl,
    required this.isOnline,
  });
}