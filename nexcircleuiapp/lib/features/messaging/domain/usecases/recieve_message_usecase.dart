import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:nexcircleuiapp/features/messaging/domain/repositories/message_repository.dart';

class ReceiveMessageUseCase {
  final MessageRepository repo;

  ReceiveMessageUseCase(this.repo);

  Stream<Message> call() {
    return repo.receiveMessage();
  }
}
