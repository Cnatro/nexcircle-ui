import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:nexcircleuiapp/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/get_friends_usecase.dart';

import '../../../auth/domain/entities/user.dart';

class FriendPage extends StatefulWidget {
  final User currentUser;

  const FriendPage({super.key, required this.currentUser});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  late GetFriendsUseCase getFriends;

  List<Map<String, dynamic>> friendsUI = [];

  int page = 0;
  final int size = 10;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final repo = ContactRepositoryImpl(ContactRemoteDataSource());
    getFriends = GetFriendsUseCase(repo);

    loadData();
  }

  void loadData() async {
    setState(() => isLoading = true);

    final List<Friendship> friends = await getFriends(page: page, size: size);

    /// 🔥 map API → UI giữ nguyên design
    final mapped = friends.map((f) {
      return {
        'name': f.fullName ?? 'Unknown',
        'lastMessage': 'Bạn bè',
        'time': 'Now',
        'unread': 0,
      };
    }).toList();

    setState(() {
      friendsUI = mapped;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async => loadData(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: friendsUI.length,
          itemBuilder: (context, index) {
            final friend = friendsUI[index];
            final name = friend['name'] as String;
            final lastMessage = friend['lastMessage'] as String;
            final time = friend['time'] as String;
            final unread = friend['unread'] as int;
            final hasUnread = unread > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xem bạn $name 👤'),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        /// Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.8),
                                const Color(0xFF8B5CF6).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lastMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Call button
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline),
                            color: const Color(0xFF6366F1),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Chat với $name 💬'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
