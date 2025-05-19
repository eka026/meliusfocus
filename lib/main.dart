// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Corrected import for FirebaseAuth to avoid conflict
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Hides AuthProvider from firebase_auth
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/focus_mode_provider.dart';
import 'providers/auth_provider.dart' as app_auth_provider; // Using an alias for clarity, or ensure your class name is unique

// Your screen imports
import 'homescreen.dart';
import 'flashcarddecks.dart';
// import 'flashcardQnA.dart'; // Assuming this is navigated to from decks screen
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
    return MultiProvider(
      providers: [
        // Use your app's AuthProvider
        ChangeNotifierProvider(create: (_) => app_auth_provider.AuthProvider()),
        ChangeNotifierProvider(create: (_) => FocusModeProvider()),
      ],
      child: MaterialApp(
        title: 'Melius Focus',
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/login': (context) => const LoginSignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/decks': (context) => FlashcardDecksScreen(),
          '/focus': (context) => FocusModeScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/profile': (context) => const ProfilePage(),
          '/spaced_repetition': (context) => const SpacedRepetitionScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to your app_auth_provider.AuthProvider's stream
    final authService = Provider.of<app_auth_provider.AuthProvider>(context, listen: true);

    return StreamBuilder<User?>( // User type from firebase_auth/firebase_auth.dart (which is not hidden)
      stream: authService.authStateChanges,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginSignupScreen();
        }
      },
    );
  }
}
