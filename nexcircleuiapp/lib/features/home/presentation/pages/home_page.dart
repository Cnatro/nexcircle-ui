import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:nexcircleuiapp/features/auth/data/repositories/user_repository_impl.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:nexcircleuiapp/features/auth/presentation/pages/profile_page.dart';
import 'package:nexcircleuiapp/features/contact/presentation/pages/contact_page.dart';
import 'package:nexcircleuiapp/features/home/presentation/pages/settings_page.dart';
import 'package:nexcircleuiapp/features/messaging/presentation/pages/conversation_page.dart';
import 'package:nexcircleuiapp/features/messaging/presentation/pages/friend_page.dart';
import '../../../auth/domain/entities/user.dart';

class HomePage extends StatefulWidget {
  final User currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ConversationPage(),
      FriendPage(currentUser: widget.currentUser),
      ContactPage(currentUser: widget.currentUser),
      SettingsPage(
        loginUseCase: LoginUseCase(
          UserRepositoryImpl(remoteDataSource: UserRemoteDataSource()),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom AppBar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                      child: const Text(
                        'Nexcircle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Chuyển sang ProfilePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfilePage(user: widget.currentUser),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.1),
                          child: Text(
                            widget.currentUser.username[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade50, Colors.white],
                ),
              ),
              child: _pages[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: _currentIndex == 0
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(
                    Icons.chat_bubble,
                    size: 24,
                    color: Color(0xFF6366F1),
                  ),
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 24,
                    color: _currentIndex == 0
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(
                    Icons.chat_bubble,
                    size: 24,
                    color: Color(0xFF6366F1),
                  ),
                ),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 24,
                    color: _currentIndex == 1
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 24,
                    color: Color(0xFF6366F1),
                  ),
                ),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: _currentIndex == 2
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(
                    Icons.settings,
                    size: 24,
                    color: Color(0xFF6366F1),
                  ),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
