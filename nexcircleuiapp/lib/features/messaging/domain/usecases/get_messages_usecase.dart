import 'package:nexcircleuiapp/features/messaging/data/models/message_model.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<MessageModel>> call({
    required String conversationId,
    page = 0,
    int size = 20,
  }) {
    return repository.getMessages(
      conversationId: conversationId,
      page: page,
      size: size,
    );
  }
}
