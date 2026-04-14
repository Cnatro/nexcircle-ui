class CallSession {
  final String sessionId;
  final String callerId;
  final String callerName;

  final String? receiverId;
  final String? receiverName;

  final String type; // AUDIO / VIDEO
  final String status; // PENDING / ACCEPTED / REJECTED / ENDED

  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;

  CallSession({
    required this.sessionId,
    required this.callerId,
    required this.callerName,
    this.receiverId,
    this.receiverName,
    required this.type,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.createdAt,
  });
}
