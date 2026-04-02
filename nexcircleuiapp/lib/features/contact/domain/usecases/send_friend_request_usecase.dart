import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class SendFriendRequestUseCase {
  final ContactRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call({required String reveiverId}) {
    return repository.sendFriendRequest( reveiverId: reveiverId);
  }
}