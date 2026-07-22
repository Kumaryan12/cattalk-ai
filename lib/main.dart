import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'ui/cattalk_theme.dart';

void main() => runApp(const CatTalkApp());

class CatTalkApp extends StatelessWidget {
  const CatTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatTalk',
      debugShowCheckedModeBanner: false,
      theme: buildCatTalkTheme(),
      home: const HomeScreen(),
    );
  }
}
