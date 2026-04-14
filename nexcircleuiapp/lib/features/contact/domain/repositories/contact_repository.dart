import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';

abstract class ContactRepository {
  Future<List<User>> getUsers({required int page, required int size});
  Future<void> sendFriendRequest({required String reveiverId});
  Future<List<FriendRequest>> getRequests({
    required int page,
    required int size,
  });
  Future<void> acceptRequest(String requestId);
  Future<List<Friendship>> getFriends({required int page, required int size});
  Future<void> removeFriend(String userId);
  Future<void> declineRequest(String requestId);
}
