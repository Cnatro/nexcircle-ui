import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';
import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class GetFriendsUseCase {
  final ContactRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<Friendship>> call({required int page, required int size}) {
    return repository.getFriends(page: page, size: size);
  }
}