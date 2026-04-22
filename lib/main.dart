import 'package:flutter/material.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/themes/MainTheme.dart';

import 'ui/screens/auth_screen.dart';

void main() {
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




