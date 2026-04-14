import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class DeclineRequestUseCase {
  final ContactRepository repository;

  DeclineRequestUseCase(this.repository);

  Future<void> excuteDecline(String requestId) {
    return repository.declineRequest(requestId);
  }
}
