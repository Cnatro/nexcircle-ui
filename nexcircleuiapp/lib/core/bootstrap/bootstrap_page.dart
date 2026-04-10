import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/core/bootstrap/my_app_flow.dart';
import 'package:nexcircleuiapp/core/service/firebase_service.dart';
import 'package:nexcircleuiapp/core/service/notification_service.dart';
import 'package:nexcircleuiapp/core/utils/shared_preferences.dart';
import 'package:nexcircleuiapp/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:nexcircleuiapp/features/auth/data/repositories/user_repository_impl.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:nexcircleuiapp/features/auth/presentation/pages/login_page.dart';
import 'package:nexcircleuiapp/features/home/presentation/pages/home_page.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({super.key});

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // init service chạy nền (KHÔNG block UI)
    await FirebaseService.init();
    await NotificationService.init();

    // dependency (giữ như main cũ)
    final userRemoteDataSource = UserRemoteDataSource();
    final userRepository = UserRepositoryImpl(
      remoteDataSource: userRemoteDataSource,
    );

    final loginUseCase = LoginUseCase(userRepository);
    final registerUseCase = RegisterUseCase(userRepository);

    // check login
    final hasToken = await AppPreferences.hasToken();

    if (!mounted) return;

    Widget startPage;

    if (hasToken) {
      final user = await userRemoteDataSource.getCurrentUser();

      if (!mounted) return;

      startPage = (user != null)
          ? HomePage(currentUser: user)
          : LoginPage(loginUseCase: loginUseCase);
    } else {
      startPage = LoginPage(loginUseCase: loginUseCase);
    }

    // chuyển sang MyAppFlow (giữ register như main cũ)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MyAppFlow(
          loginUseCase: loginUseCase,
          registerUseCase: registerUseCase,
          startPage: startPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
