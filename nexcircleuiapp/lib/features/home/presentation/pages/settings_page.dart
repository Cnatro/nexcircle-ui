import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:nexcircleuiapp/features/auth/presentation/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  final LoginUseCase loginUseCase; // để redirect lại login
  const SettingsPage({Key? key, required this.loginUseCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          onPressed: () async {
            await AppPreferences.removeToken(); // xóa token
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => LoginPage(loginUseCase: loginUseCase),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
