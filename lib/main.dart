import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'flashcarddecks.dart';
import 'flashcardQnA.dart';
import 'FocusMode.dart';
import 'leaderboard.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melius Focus',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/decks': (context) => FlashcardDecksScreen(),
        '/flashcard': (context) => FlashcardScreen(),
        '/focus': (context) => FocusModeScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
