import '../../domain/entities/conversation.dart';
import 'participant_model.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.type,
    super.name,
    super.avatar,
    required super.participants,
    super.lastMessage,
    required super.unreadCount,
    required super.mute,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      avatar: json['avatar'],
      participants: (json['participants'] as List)
          .map((e) => ParticipantModel.fromJson(e))
          .toList(),
      lastMessage: null, // map sau nếu cần
      unreadCount: json['unreadCount'] ?? 0,
      mute: json['mute'] ?? false,
    );
  }
}