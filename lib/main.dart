import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CatTalkApp());
}

class CatTalkApp extends StatelessWidget {
  const CatTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatTalk AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}