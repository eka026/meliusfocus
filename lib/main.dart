import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'flashcarddecks.dart';
import 'flashcardQnA.dart';
import 'FocusMode.dart';
import 'leaderboard.dart';
import 'settings.dart';
import 'login_signup_screen.dart';
import 'profile_page.dart';
import 'spaced_repetition.dart';
import 'routes.dart';
import 'screens/login_signup_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melius Focus',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'PlayfairDisplay',
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // or '/' if you prefer to land on Home directly
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
