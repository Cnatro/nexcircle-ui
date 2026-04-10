import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:nexcircleuiapp/features/messaging/data/datasources/message_socket_data_source.dart';
import 'package:nexcircleuiapp/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/message.dart';
import 'package:nexcircleuiapp/features/messaging/domain/usecases/get_messages_usecase.dart';

class ChatPage extends StatefulWidget {
  final Conversation? conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final MessageSocketDataSource socket = MessageSocketDataSource();
  StreamSubscription? _sub;

  List<Map<String, Object>> messages = [];

  String? currentUserId;
  User currentUserJson = User(id: "", username: "", email: "");

  late GetMessagesUseCase getMessagesUseCase;

  @override
  void initState() {
    super.initState();

    if (widget.conversation == null) {
      throw Exception("ChatPage cần conversation hoặc friend");
    }

    final remote = MessageRemoteDataSource();
    final repo = MessageRepositoryImpl(socket: socket, remote: remote);
    getMessagesUseCase = GetMessagesUseCase(repo);

    loadMessages();
    initSocket();
  }

  /// Load messages (GIỮ NGUYÊN)
  Future<void> loadMessages() async {
    if (widget.conversation == null) return;

    currentUserId = await AppPreferences.getUserId();

    try {
      final result = await getMessagesUseCase(
        conversationId: widget.conversation!.id,
        page: 0,
        size: 20,
      );

      setState(() {
        messages = result.reversed.map((msg) {
          return <String, Object>{
            "isMe": msg.sender.id == currentUserId!,
            "text": msg.content ?? "",
          };
        }).toList();
      });

      scrollToBottom();
    } catch (e) {
      print("Load message error: $e");
    }
  }

  /// Socket init (GIỮ NGUYÊN)
  Future<void> initSocket() async {
    final token = await AppPreferences.getToken();
    final userId = await AppPreferences.getUserId();
    final userJson = await AppPreferences.getUser();

    if (token == null || userId == null || userJson == null) return;

    currentUserId = userId;
    currentUserJson = userJson;

    socket.connect(token: token, conversationId: widget.conversation?.id ?? "");

    _sub = socket.onMessage().listen((msg) {
      final isMe = msg.senderId == currentUserId;

      final isDuplicate = messages.any(
        (m) => m["text"] == msg.content && m["isMe"] == isMe,
      );

      if (!isDuplicate) {
        setState(() {
          messages.add({"isMe": isMe, "text": msg.content ?? ""});
        });
        scrollToBottom();
      }
    });
  }

  // =========================
  // ✅ FIX PART: CONVERSATION LOGIC
  // =========================

  String getReceiverId() {
    final participants = widget.conversation?.participants ?? [];

    if (participants.isEmpty || currentUserId == null) return "";

    final other = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );

    return other.userId ?? "";
  }

  String _getPrivateName() {
    final participants = widget.conversation?.participants ?? [];

    if (participants.isEmpty || currentUserId == null) return 'User';

    final other = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );

    return (other.fullName != null && other.fullName!.trim().isNotEmpty)
        ? other.fullName!
        : (other.userName != null && other.userName!.trim().isNotEmpty)
        ? other.userName!
        : 'User';
  }

  String getAvatar() {
    final participants = widget.conversation?.participants ?? [];

    if (participants.isEmpty || currentUserId == null) return '';

    final other = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );

    return other.avatarUrl ?? '';
  }

  String getTitle() {
    if (widget.conversation == null) return 'Unknown';

    if (widget.conversation!.type == 'private') {
      return _getPrivateName();
    }

    return widget.conversation!.name ?? 'Group';
  }

  // =========================
  // ✅ FIX SEND MESSAGE
  // =========================

  void sendMessage() async {
    final content = _controller.text.trim();

    if (content.isEmpty || widget.conversation == null || currentUserId == null)
      return;

    final message = Message(
      senderId: currentUserId!,
      conversationId: widget.conversation!.id,
      content: content,
      receiverId: getReceiverId(), // ✅ FIX HERE
      messageType: "text",
      parentMessageId: null,
    );

    socket.sendMessage(message);

    setState(() {
      messages.add({"isMe": true, "text": content});
    });

    _controller.clear();
    FocusScope.of(context).unfocus();

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

  @override
  void dispose() {
    _sub?.cancel();
    socket.disconnect();
    _controller.dispose();
    _scrollController.dispose();
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["isMe"] as bool;

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
                      msg["text"] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
                    onSubmitted: (_) => sendMessage(),
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
// class ChatPage extends StatefulWidget {
//   final Conversation? conversation;

//   const ChatPage({super.key, required this.conversation});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   final MessageSocketDataSource socket = MessageSocketDataSource();
//   StreamSubscription? _sub;

//   // Chú ý: messages kiểu Map<String, Object> để tránh lỗi dynamic vs Object
//   List<Map<String, Object>> messages = [];

//   String? currentUserId;
//   User currentUserJson = User(id: "", username: "", email: "");
//   late GetMessagesUseCase getMessagesUseCase;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.conversation == null) {
//       throw Exception("ChatPage cần conversation hoặc friend");
//     }

//     final remote = MessageRemoteDataSource();
//     final repo = MessageRepositoryImpl(socket: socket, remote: remote);
//     getMessagesUseCase = GetMessagesUseCase(repo);

//     loadMessages();
//     initSocket();
//   }

//   /// Load tin nhắn từ server
//   Future<void> loadMessages() async {
//     if (widget.conversation == null) return;

//     currentUserId = await AppPreferences.getUserId();

//     try {
//       final result = await getMessagesUseCase(
//         conversationId: widget.conversation!.id,
//         page: 0,
//         size: 20,
//       );

//       setState(() {
//         messages = result.reversed.map((msg) {
//           return <String, Object>{
//             "isMe": msg.sender.id == currentUserId!,
//             "text": msg.content ?? "",
//           };
//         }).toList();
//       });

//       scrollToBottom();
//     } catch (e) {
//       print("Load message error: $e");
//     }
//   }

//   /// Khởi tạo socket, lắng nghe tin nhắn realtime
//   Future<void> initSocket() async {
//     final token = await AppPreferences.getToken();
//     final userId = await AppPreferences.getUserId();
//     final userJson = await AppPreferences.getUser();

//     if (token == null || userId == null || userJson == null) return;

//     currentUserId = userId;
//     currentUserJson = userJson;

//     socket.connect(token: token, conversationId: widget.conversation?.id ?? "");

//     _sub = socket.onMessage().listen((msg) {
//       final isMe = msg.senderId == currentUserId;
//       final isDuplicate = messages.any(
//         (m) => m["text"] == msg.content && m["isMe"] == isMe,
//       );
//       if (!isDuplicate) {
//         setState(() {
//           messages.add({"isMe": isMe, "text": msg.content ?? ""});
//         });
//         scrollToBottom();
//       }
//     });
//   }

//   /// Gửi tin nhắn
//   void sendMessage() async {
//     final content = _controller.text.trim();
//     if (content.isEmpty || widget.conversation == null || currentUserId == null)
//       return;

//     final message = Message(
//       senderId: currentUserId!,
//       conversationId: widget.conversation!.id,
//       content: content,
//       receiverId: widget.conversation?.participants.first.userId ?? "",
//       messageType: "text",
//       parentMessageId: null,
//     );

//     // Gửi tin nhắn qua socket
//     socket.sendMessage(message);

//     // Thêm ngay vào danh sách để hiển thị realtime
//     setState(() {
//       messages.add(<String, Object>{"isMe": true, "text": content});
//     });

//     // Clear input và mất focus
//     _controller.clear();
//     FocusScope.of(context).unfocus();

//     scrollToBottom();
//   }

//   void scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   String getTitle() {
//     if (widget.conversation != null) {
//       if (widget.conversation!.type == 'private') {
//         return _getPrivateName();
//       }
//       return widget.conversation!.name ?? 'Group';
//     }
//     return 'Unknown';
//   }

//   String getAvatar() {
//     if (widget.conversation != null && widget.conversation!.avatar != null) {
//       return widget.conversation!.avatar!;
//     }
//     return '';
//   }

//   String _getPrivateName() {
//     final participants = widget.conversation?.participants ?? [];
//     if (participants.isEmpty) return 'User';
//     return participants.first.fullName ?? 'User';
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     socket.disconnect();
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final avatar = getAvatar();
//     final title = getTitle();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
//               child: avatar.isEmpty
//                   ? Text(title.isNotEmpty ? title[0] : '?')
//                   : null,
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const Text(
//                   "Online",
//                   style: TextStyle(color: Colors.green, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(12),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 final isMe = msg["isMe"] as bool;
//                 return Align(
//                   alignment: isMe
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.7,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isMe ? const Color(0xFF6366F1) : Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       msg["text"] as String,
//                       style: TextStyle(
//                         color: isMe ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                       border: InputBorder.none,
//                     ),
//                     onSubmitted: (_) => sendMessage(),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
