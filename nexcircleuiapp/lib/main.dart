import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nexcircleuiapp/core/bootstrap/bootstrap_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  print("API_URL = ${dotenv.env['API_URL']}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexCircle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BootstrapPage(),
    );
  }
}
