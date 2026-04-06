import '../../domain/entities/participant.dart';

class ParticipantModel extends Participant {
  ParticipantModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.userName,
    super.avatarUrl,
    required super.isOnline,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
    );
  }
}
