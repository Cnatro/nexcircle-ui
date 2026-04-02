import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class GetFriendRequestsUseCase {
  final ContactRepository repository;

  GetFriendRequestsUseCase(this.repository);

  Future<List<FriendRequest>> call({required int page, required int size}) {
    return repository.getRequests(page:page, size:size);
  }
}
