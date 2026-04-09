import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/utils/top_snackbar.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friend_request.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/accept_request_usecase.dart';

class RequestTile extends StatelessWidget {
  final FriendRequest request;
  final AcceptRequestUseCase acceptRequestUseCase;
  final VoidCallback onAccepted;

  const RequestTile({
    super.key,
    required this.request,
    required this.acceptRequestUseCase,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(request.senderName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              await acceptRequestUseCase.call(request.id);

              onAccepted();

              showTopBanner(
                context,
                'Đã chấp nhật lời mời!',
                color: Colors.green,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
