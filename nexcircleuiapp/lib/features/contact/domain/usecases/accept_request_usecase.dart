import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class AcceptRequestUseCase {
  final ContactRepository repository;

  AcceptRequestUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.acceptRequest(requestId);
  }
}