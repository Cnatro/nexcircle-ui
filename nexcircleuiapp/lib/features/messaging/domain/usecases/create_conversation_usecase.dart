import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class CreateConversationUseCase {
  final MessageRepository repo;

  CreateConversationUseCase(this.repo);

  Future<Conversation> call({
    required String name,
    required String type,
    required List<String> userIds,
    String? avatar,
  }) {
    return repo.createConversation(name: name, type: type, userIds: userIds, avatar: avatar);
  }
}
