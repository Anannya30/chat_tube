import 'package:flutter/material.dart';
import 'package:chat_tube/features/home/screens/home_screen.dart';
import 'core/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Chat Tube', theme: theme, home: HomeScreen());
  }
}
