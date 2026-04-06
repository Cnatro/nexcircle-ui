import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository repo;

  SendMessageUseCase(this.repo);

  void call(Message message) {
    repo.sendMessage(message);
  }
}