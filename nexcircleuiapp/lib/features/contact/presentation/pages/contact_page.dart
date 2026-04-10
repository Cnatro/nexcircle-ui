import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/auth/domain/entities/user.dart';
import 'package:nexcircleuiapp/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:nexcircleuiapp/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/accept_request_usecase.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/get_friend_requests_usecase.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/get_users_usecase.dart';
import 'package:nexcircleuiapp/features/contact/domain/usecases/send_friend_request_usecase.dart';
import 'package:nexcircleuiapp/features/contact/presentation/widgets/request_tile.dart';
import 'package:nexcircleuiapp/features/contact/presentation/widgets/user_tile.dart';

class ContactPage extends StatefulWidget {
  final User currentUser;

  const ContactPage({super.key, required this.currentUser});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  late GetUsersUseCase getUsers;
  late GetFriendRequestsUseCase getRequests;
  late SendFriendRequestUseCase sendFriendRequestUseCase;
  late AcceptRequestUseCase acceptRequestUseCase;

  List users = [];
  List requests = [];

  int page = 0;
  final int size = 10;

  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final repo = ContactRepositoryImpl(ContactRemoteDataSource());

    getUsers = GetUsersUseCase(repo);
    getRequests = GetFriendRequestsUseCase(repo);
    sendFriendRequestUseCase = SendFriendRequestUseCase(repo);
    acceptRequestUseCase = AcceptRequestUseCase(repo);

    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadData() async {
    setState(() => isLoading = true);

    final u = await getUsers(page: page, size: size);
    final r = await getRequests(page: page, size: size);

    setState(() {
      users = u;
      requests = r;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF6366F1),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1, size: 18),
                      const SizedBox(width: 8),
                      const Text("Thêm bạn"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 18),
                      const SizedBox(width: 8),
                      const Text("Lời mời"),
                      if (requests.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Content
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải danh bạ...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      /// ADD FRIEND Tab
                      RefreshIndicator(
                        color: const Color(0xFF6366F1),
                        onRefresh: () async => loadData(),
                        child: users.isEmpty
                            ? _buildEmptyState(
                                icon: Icons.people_outline,
                                title: 'Không tìm thấy người dùng',
                                subtitle: 'Hãy thử tìm kiếm bạn bè để kết nối',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: users.length,
                                itemBuilder: (_, i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: UserTile(
                                    user: users[i],
                                    sendFriendRequestUseCase:
                                        sendFriendRequestUseCase,
                                    onRequestSent: () {
                                      setState(() {
                                        users.removeAt(i);
                                      });
                                    },
                                  ),
                                ),
                              ),
                      ),

                      /// REQUESTS Tab
                      RefreshIndicator(
                        color: const Color(0xFF6366F1),
                        onRefresh: () async => loadData(),
                        child: requests.isEmpty
                            ? _buildEmptyState(
                                icon: Icons.person_add_disabled,
                                title: 'Không có lời mời kết bạn',
                                subtitle:
                                    'Khi ai đó gửi lời mời, nó sẽ hiển thị ở đây',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: requests.length,
                                itemBuilder: (_, i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: RequestTile(
                                    request: requests[i],
                                    acceptRequestUseCase: acceptRequestUseCase,
                                    onAccepted: () {
                                      setState(() {
                                        requests.removeAt(i);
                                      });
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
