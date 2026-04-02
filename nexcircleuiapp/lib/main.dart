import 'package:flutter/material.dart';
import 'features/auth/data/datasources/user_remote_data_source.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final userRemoteDataSource = UserRemoteDataSource();
  final userRepository = UserRepositoryImpl(
    remoteDataSource: userRemoteDataSource,
  );
  final loginUseCase = LoginUseCase(userRepository);
  final registerUseCase = RegisterUseCase(userRepository);

  // Kiểm tra token và current user
  Widget startPage;

  final hasToken = await AppPreferences.hasToken();
  if (hasToken) {
    final user = await userRemoteDataSource.getCurrentUser();
    if (user != null) {
      startPage = HomePage(currentUser: user); // truyền user đúng
    } else {
      startPage = LoginPage(
        loginUseCase: loginUseCase,
      ); // truyền loginUseCase thực
    }
  } else {
    startPage = LoginPage(
      loginUseCase: loginUseCase,
    ); // truyền loginUseCase thực
  }

  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      startPage: startPage,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final Widget startPage;

  MyApp({
    Key? key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.startPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexCircle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: startPage,
      routes: {
        '/register': (_) => RegisterPage(registerUseCase: registerUseCase),
      },
    );
  }
}
