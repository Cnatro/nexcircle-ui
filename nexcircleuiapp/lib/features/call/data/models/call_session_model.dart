import 'package:nexcircleuiapp/features/call/domain/entities/call_session.dart';

class CallSessionModel extends CallSession {
  CallSessionModel({
    required super.sessionId,
    required super.callerId,
    required super.callerName,
    required super.receiverId,
    required super.receiverName,
    required super.type,
    required super.status,
    required super.startedAt,
    super.endedAt,
    super.createdAt,
  });

  factory CallSessionModel.fromJson(Map<String, dynamic> json) {
    return CallSessionModel(
      sessionId: json['sessionId'] ?? "",
      callerId: json['callerId'] ?? "",
      callerName: json['callerName'] ?? "",
      receiverId: json['receiverId'] ?? "",
      receiverName: json['receiverName'] ?? "",
      type: json['type'] ?? "AUDIO",
      status: json['status'] ?? "PENDING",

      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),

      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
