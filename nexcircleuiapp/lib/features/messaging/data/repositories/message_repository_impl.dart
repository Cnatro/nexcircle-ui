import 'package:nexcircleuiapp/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:nexcircleuiapp/features/messaging/data/datasources/message_socket_data_source.dart';
import 'package:nexcircleuiapp/features/messaging/data/models/message_model.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageSocketDataSource? socket;
  final MessageRemoteDataSource remote;

  MessageRepositoryImpl({this.socket, required this.remote});

  @override
  Stream<Message> receiveMessage() {
    if (socket == null) {
      throw Exception("Socket not initialized");
    }
    return socket!.onMessage();
  }

  @override
  Future<Conversation> createConversation({
    required String name,
    required String type,
    required List<String> userIds,
  }) {
    return remote.createConversation(name: name, type: type, userIds: userIds);
  }

  @override
  Future<List<Conversation>> getConversations({
    required int page,
    required int size,
  }) {
    return remote.getConversations(page: page, size: size);
  }

  @override
  Future<void> connect(String token, String conversationId) async {
    if (socket == null) {
      throw Exception("Socket not initialized");
    }
    socket!.connect(token: token, conversationId: conversationId);
  }

  @override
  Future<void> sendMessage(Message message) async {
    if (socket == null) {
      throw Exception("Socket not initialized");
    }
    socket!.sendMessage(message);
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required int page,
    required int size,
  }) {
    return remote.getMessages(
      conversationId: conversationId,
      page: page,
      size: size,
    );
  }
}
