import 'package:flutter/material.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:nexcircleuiapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:nexcircleuiapp/features/auth/presentation/pages/register_page.dart';

class MyAppFlow extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final Widget startPage;

  const MyAppFlow({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.startPage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexCircle',
      theme: ThemeData(primarySwatch: Colors.blue),

      home: startPage,

      routes: {
        '/register': (_) => RegisterPage(registerUseCase: registerUseCase),
      },
    );
  }
}
