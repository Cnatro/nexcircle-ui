import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class GetConversationsUseCase {
  final MessageRepository repo;

  GetConversationsUseCase(this.repo);

  Future<List<Conversation>> call() {
    return repo.getConversations(page: 1, size: 20);
  }
}
