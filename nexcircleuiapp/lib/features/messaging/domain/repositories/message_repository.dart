import 'package:nexcircleuiapp/features/messaging/data/models/message_model.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';

abstract class MessageRepository {
  Stream<Message> receiveMessage();
  Future<void> sendMessage(Message message);
  Future<void> connect(String token, String userId);
  Future<List<Conversation>> getConversations({
    required int page,
    required int size,
  });
  Future<Conversation> createConversation({
    required String name,
    required String type,
    required List<String> userIds,
  });
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required int page,
    required int size,
  });
}
