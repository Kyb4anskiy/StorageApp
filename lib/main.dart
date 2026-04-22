import 'package:flutter/material.dart';
import 'package:flutter_app/data/HelperDB.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';
import 'package:flutter_app/ui/themes/MainTheme.dart';

import 'ui/screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HelperDB.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Flutter App',
      theme: MainTheme.light,
      home: const HomeScreen(),
    );
  }
}




