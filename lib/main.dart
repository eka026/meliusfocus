import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homescreen.dart';
import 'flashcarddecks.dart';
import 'flashcardQnA.dart';
import 'FocusMode.dart';
import 'leaderboard.dart';
import 'settings.dart';
import 'login_signup_screen.dart';
import 'profile_page.dart';
import 'spaced_repetition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melius Focus',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginSignupScreen(),
        '/': (context) => const HomeScreen(),
        '/decks': (context) => FlashcardDecksScreen(),
        '/focus': (context) => FocusModeScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfilePage(),
        '/spaced_repetition' : (context) => const SpacedRepetitionScreen(),
      },
    );
  }
}
