import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class RemoveFriendUsecase {
  final ContactRepository repository;
  RemoveFriendUsecase(this.repository);

  Future<void> excuteRemove(String friendId) {
    return repository.removeFriend(friendId);
  }
}
