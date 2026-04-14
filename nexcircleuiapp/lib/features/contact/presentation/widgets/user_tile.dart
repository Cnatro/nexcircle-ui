import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/utils/top_snackbar.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/send_friend_request_usecase.dart';

class UserTile extends StatelessWidget {
  final User user;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final VoidCallback? onRequestSent;

  const UserTile({
    super.key,
    required this.user,
    required this.sendFriendRequestUseCase,
    this.onRequestSent,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.username),
      trailing: ElevatedButton(
        onPressed: () async {
          try {
            await sendFriendRequestUseCase.call(reveiverId: user.id);
            onRequestSent?.call();

            showTopBanner(
              context,
              'Gửi lời mời thành công!',
              color: Colors.green,
            );
          } catch (e) {
            showTopBanner(context, 'Gửi lời mời thất bại!', color: Colors.red);
          }
        },
        child: const Text("Add"),
      ),
    );
  }
}
