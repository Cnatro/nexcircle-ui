import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/messaging/data/datasources/message_remote_datasource.dart';
import 'package:nexcircleuiapp/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:nexcircleuiapp/features/messaging/domain/entities/conversation.dart';
import 'package:nexcircleuiapp/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:nexcircleuiapp/features/messaging/presentation/pages/chat_page.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late GetConversationsUseCase getConversations;

  List<Map<String, dynamic>> conversationsUI = [];
  List<Conversation> conversations = [];
  List<Map<String, dynamic>> filteredConversationsUI = [];
  List<Conversation> filteredConversations = [];

  int page = 0;
  final int size = 10;

  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final repo = MessageRepositoryImpl(remote: MessageRemoteDataSource());
    getConversations = GetConversationsUseCase(repo);

    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final result = await getConversations();

    if (!mounted) return;

    final mapped = result.map((c) {
      final name = c.displayName;

      return {
        'name': name,
        'lastMessage': c.lastMessage?.content ?? 'Chưa có tin nhắn',
        'time': 'Now',
        'unread': c.unreadCount,
      };
    }).toList();

    setState(() {
      conversations = result;
      conversationsUI = mapped;
      filteredConversations = result;
      filteredConversationsUI = mapped;
      isLoading = false;
    });
  }

  void searchConversations(String query) {
    if (!mounted) return;

    if (query.isEmpty) {
      setState(() {
        filteredConversations = conversations;
        filteredConversationsUI = conversationsUI;
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      filteredConversations = [];
      filteredConversationsUI = [];

      for (int i = 0; i < conversations.length; i++) {
        if (conversations[i].displayName.toLowerCase().contains(
          query.toLowerCase(),
        )) {
          filteredConversations.add(conversations[i]);
          filteredConversationsUI.add(conversationsUI[i]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    final displayConversations = isSearching
        ? filteredConversations
        : conversations;
    final displayConversationsUI = isSearching
        ? filteredConversationsUI
        : conversationsUI;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: searchConversations,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm cuộc trò chuyện...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          searchController.clear();
                          searchConversations('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),

        // Conversation List
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadData,
            color: const Color(0xFF6366F1),
            child: displayConversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.1),
                                const Color(0xFF8B5CF6).withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSearching
                                ? Icons.search_off
                                : Icons.chat_bubble_outline,
                            size: 50,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isSearching
                              ? "Không tìm thấy kết quả"
                              : "Chưa có tin nhắn",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSearching
                              ? "Hãy thử tìm kiếm với từ khóa khác"
                              : "Hãy bắt đầu một cuộc trò chuyện mới",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: displayConversationsUI.length,
                    itemBuilder: (context, index) {
                      final item = displayConversationsUI[index];
                      final c = displayConversations[index];

                      final name = item['name'] as String;
                      final lastMessage = item['lastMessage'] as String;
                      final time = item['time'] as String;
                      final unread = item['unread'] as int;
                      final hasUnread = unread > 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChatPage(conversation: c, friend: null),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  /// Avatar
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: hasUnread
                                            ? [
                                                const Color(0xFFF59E0B),
                                                const Color(0xFFF97316),
                                              ]
                                            : [
                                                const Color(0xFF6366F1),
                                                const Color(0xFF8B5CF6),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (hasUnread
                                                      ? const Color(0xFFF59E0B)
                                                      : const Color(0xFF6366F1))
                                                  .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.transparent,
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 22,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  color: hasUnread
                                                      ? const Color(0xFF1A1A2E)
                                                      : Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              time,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                lastMessage,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: hasUnread
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade600,
                                                  fontWeight: hasUnread
                                                      ? FontWeight.w500
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (hasUnread)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFF59E0B),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '$unread',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
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
        ),
      ],
    );
  }
}
