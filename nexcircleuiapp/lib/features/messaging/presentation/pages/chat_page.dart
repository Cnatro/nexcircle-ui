import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/contact/domain/entities/friendship.dart';
import 'package:nexcircleuiapp/features/messaging/data/datasources/message_socket_data_source.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';

class ChatPage extends StatefulWidget {
  final Friendship? friend;
  final Conversation? conversation;

  const ChatPage({super.key, required this.friend, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final MessageSocketDataSource socket = MessageSocketDataSource();
  StreamSubscription? _sub;

  List<Map<String, dynamic>> messages = [];

  String? currentUserId;

  @override
  void initState() {
    super.initState();

    if (widget.conversation == null && widget.friend == null) {
      throw Exception("ChatPage cần conversation hoặc friend");
    }

    loadMessages();
    initSocket();
  }

  /// ✅ CONNECT SOCKET
  void initSocket() async {
    final token = await AppPreferences.getToken();
    currentUserId = await AppPreferences.getUserId();

    if (token == null || currentUserId == null) return;

    socket.connect(token: token, userId: currentUserId!);

    /// listen realtime
    _sub = socket.onMessage().listen((msg) {
      if (msg.conversationId != widget.conversation?.id) return;

      setState(() {
        messages.add({
          "isMe": msg.senderId == currentUserId,
          "text": msg.content,
        });
      });

      scrollToBottom();
    });
  }

  void loadMessages() {
    setState(() {
      messages = [
        {"isMe": false, "text": "Hello 👋"},
        {"isMe": true, "text": "Hi, how are you?"},
        {"isMe": false, "text": "I'm good, what about you?"},
      ];
    });
  }

  /// ✅ SEND SOCKET
  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    if (widget.conversation == null) return;
    if (currentUserId == null) return;

    final content = _controller.text.trim();

    final message = Message(
      senderId: currentUserId!,
      conversationId: widget.conversation!.id,
      content: content,
    );

    socket.sendMessage(message); // 👈 gửi realtime

    /// UI local
    setState(() {
      messages.add({"isMe": true, "text": content});
    });

    _controller.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getTitle() {
    if (widget.conversation != null) {
      if (widget.conversation!.type == 'private') {
        return _getPrivateName();
      }
      return widget.conversation!.name ?? 'Group';
    }
    return widget.friend?.fullName ?? 'Unknown';
  }

  String getAvatar() {
    if (widget.conversation != null && widget.conversation!.avatar != null) {
      return widget.conversation!.avatar!;
    }
    return widget.friend?.avatarUrl ?? '';
  }

  String _getPrivateName() {
    final participants = widget.conversation?.participants ?? [];

    if (participants.isEmpty) {
      return widget.friend?.fullName ?? 'User';
    }

    return participants.first.fullName ?? 'User';
  }

  @override
  void dispose() {
    _sub?.cancel();
    socket.disconnect(); // 👈 QUAN TRỌNG
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = getAvatar();
    final title = getTitle();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? Text(title.isNotEmpty ? title[0] : '?')
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          /// MESSAGE LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["isMe"];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF6366F1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../../auth/domain/entities/user.dart';

// class ChatPage extends StatelessWidget {
//   final User currentUser;
//   const ChatPage({super.key, required this.currentUser});

//   @override
//   Widget build(BuildContext context) {
//     // Example dữ liệu chat với kiểu dữ liệu rõ ràng
//     final List<Map<String, dynamic>> chats = [
//       {
//         'name': 'Alice',
//         'lastMessage': 'Hi there!',
//         'time': '10:30 AM',
//         'unread': 2,
//       },
//       {'name': 'Bob', 'lastMessage': 'Hello!', 'time': '09:15 AM', 'unread': 0},
//       {
//         'name': 'Charlie',
//         'lastMessage': 'How are you?',
//         'time': 'Yesterday',
//         'unread': 1,
//       },
//       {
//         'name': 'David',
//         'lastMessage': 'See you tomorrow',
//         'time': 'Yesterday',
//         'unread': 0,
//       },
//       {'name': 'Emma', 'lastMessage': 'Thanks!', 'time': 'Monday', 'unread': 3},
//     ];

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: chats.length,
//         itemBuilder: (context, index) {
//           final chat = chats[index];
//           final name = chat['name'] as String;
//           final lastMessage = chat['lastMessage'] as String;
//           final time = chat['time'] as String;
//           final unread = chat['unread'] as int;
//           final hasUnread = unread > 0;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade200,
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Open chat with $name ✨'),
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       backgroundColor: const Color(0xFF6366F1),
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(20),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       // Avatar
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             colors: [
//                               const Color(0xFF6366F1).withOpacity(0.8),
//                               const Color(0xFF8B5CF6).withOpacity(0.8),
//                             ],
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFF6366F1).withOpacity(0.2),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.transparent,
//                           child: Text(
//                             name[0].toUpperCase(),
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Content
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     name,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: hasUnread
//                                           ? FontWeight.bold
//                                           : FontWeight.w600,
//                                       color: Colors.grey.shade800,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   time,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     lastMessage,
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: hasUnread
//                                           ? FontWeight.w600
//                                           : FontWeight.normal,
//                                       color: hasUnread
//                                           ? Colors.grey.shade800
//                                           : Colors.grey.shade600,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 if (hasUnread)
//                                   Container(
//                                     margin: const EdgeInsets.only(left: 8),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [
//                                           Color(0xFF6366F1),
//                                           Color(0xFF8B5CF6),
//                                         ],
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Text(
//                                       '$unread',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Call Button
//                       Container(
//                         margin: const EdgeInsets.only(left: 8),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF6366F1).withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.call_outlined, size: 22),
//                           color: const Color(0xFF6366F1),
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Calling $name... 📞'),
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 backgroundColor: const Color(0xFF10B981),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
