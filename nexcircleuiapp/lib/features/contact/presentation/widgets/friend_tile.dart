import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';

class FriendTile extends StatelessWidget {
  final Friendship friend;

  const FriendTile({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(friend.fullName),
      trailing: const Icon(Icons.chat),
    );
  }
}