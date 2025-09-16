import 'package:flutter/material.dart';
import 'screens/game_menu.dart';

void main() => runApp(const GameApp());

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oyun Merkezi',
      theme: ThemeData.dark(),
      home: const GameMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}


