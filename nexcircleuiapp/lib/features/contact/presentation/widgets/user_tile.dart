import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/send_friend_request_usecase.dart';

class UserTile extends StatelessWidget {
  final User user;
  final SendFriendRequestUseCase sendFriendRequestUseCase;

  const UserTile({super.key, required this.user, required this.sendFriendRequestUseCase});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.username),
      trailing: ElevatedButton(
        onPressed: () {
          sendFriendRequestUseCase.call(reveiverId: user.id);
        },
        child: const Text("Add"),
      ),
    );
  }
}