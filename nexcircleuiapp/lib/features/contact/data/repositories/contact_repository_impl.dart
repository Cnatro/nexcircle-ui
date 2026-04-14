import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';
import 'package:nexcircleuiapp/features/contact/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remote;

  ContactRepositoryImpl(this.remote);

  @override
  Future<List<User>> getUsers({required int page, required int size}) {
    return remote.getUsers(page: page, size: size);
  }

  @override
  Future<void> sendFriendRequest({required String reveiverId}) {
    return remote.sendFriendRequest(recieverId: reveiverId, status: 'pending');
  }

  @override
  Future<List<FriendRequest>> getRequests({
    required int page,
    required int size,
  }) {
    return remote.getRequests(page: page, size: size);
  }

  @override
  Future<void> acceptRequest(String requestId) =>
      remote.acceptRequest(requestId);

  @override
  Future<List<Friendship>> getFriends({required int page, required int size}) {
    return remote.getFriends(page: page, size: size);
  }

  @override
  Future<void> removeFriend(String friendId) {
    return remote.removeFriend(friendId);
  }
  
  @override
  Future<void> declineRequest(String requestId) {
    return remote.declineRequest(requestId);
  }

  
}
