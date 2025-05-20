// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Hides AuthProvider from firebase_auth
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/focus_mode_provider.dart';
import 'providers/auth_provider.dart' as app_auth_provider;
import 'providers/leaderboard_provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/theme_provider.dart';

// Your screen imports
import 'homescreen.dart';
import 'flashcarddecks.dart';
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
        ChangeNotifierProvider(create: (_) => app_auth_provider.AuthProvider()),
        ChangeNotifierProvider(create: (_) => FocusModeProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider(context)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Melius Focus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, navigatorWidget) {
            final authProvider = context.watch<app_auth_provider.AuthProvider>();
            final User? currentUser = authProvider.user;
            print("[MyApp MaterialApp.builder] Watched AuthProvider. User: ${currentUser?.uid}");
            return navigatorWidget!;
          },
          home: AuthWrapper(),
          routes: {
            '/login': (context) => const LoginSignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/decks': (context) => FlashcardDecksScreen(),
            '/focus': (context) => FocusModeScreen(),
            '/leaderboard': (context) => LeaderboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/profile': (context) => const ProfilePage(),
            '/spaced_repetition': (context) => const SpacedRepetitionScreen(),
          },
        ),
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key}); 

  @override
  Widget build(BuildContext context) {
    print("AuthWrapper: Build method started.");
    final authProvider = context.watch<app_auth_provider.AuthProvider>();
    print("AuthWrapper: Got authProvider. Checking user state.");
    final User? currentUser = authProvider.user;

    print("AuthWrapper: currentUser from AuthProvider: ${currentUser?.uid}");

    if (currentUser != null) {
      print("AuthWrapper: User is present (${currentUser.uid}), navigating to HomeScreen.");
      Future.microtask(() {
        print("AuthWrapper: Microtask navigating to HomeScreen for User UID: ${currentUser.uid}");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator(key: ValueKey("loading_authwrapper"))));
    } else {
      print("AuthWrapper: User is NOT present, showing LoginSignupScreen.");
      return const LoginSignupScreen(key: ValueKey("loginScreen_authwrapper"));
    }
  }
}