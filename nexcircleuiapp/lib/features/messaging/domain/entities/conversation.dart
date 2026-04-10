import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/participant.dart';

class Conversation {
  final String id;
  final String type;
  final String? name;
  final String? avatar;
  final List<Participant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final bool mute;

  Conversation({
    required this.id,
    required this.type,
    this.name,
    this.avatar,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.mute,
  });

  bool get isGroup => type == "group";
}
