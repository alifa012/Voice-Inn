import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VoiceInnApp());
}

class VoiceInnApp extends StatelessWidget {
  const VoiceInnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice-INN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // starting point
    );
  }
}
