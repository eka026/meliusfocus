import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/login_signup_screen.dart';
import 'utils/app_colors.dart';

void main() => runApp(const MeliusApp());

class MeliusApp extends StatelessWidget {
  const MeliusApp({super.key});

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
      initialRoute: routeLogin,
      routes: {
        routeLogin: (_) => const LoginSignupScreen()
      },
    );
  }
}
