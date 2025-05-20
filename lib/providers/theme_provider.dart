import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as app_auth;

class ThemeProvider with ChangeNotifier {
  static const String _defaultTheme = 'light';
  String _themeMode = _defaultTheme;
  String get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == 'dark';

  ThemeProvider(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    authProvider.addListener(() {
      loadThemeForUser(authProvider.user);
    });
    loadThemeForUser(authProvider.user);
  }

  Future<void> loadThemeForUser(User? user) async {
    if (user == null) {
      _themeMode = _defaultTheme;
      notifyListeners();
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null && data['themeMode'] != null) {
      _themeMode = data['themeMode'];
    } else {
      _themeMode = _defaultTheme;
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool value, {User? user}) async {
    final mode = value ? 'dark' : 'light';
    _themeMode = mode;
    notifyListeners();
    final currentUser = user ?? FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'themeMode': mode,
      }, SetOptions(merge: true));
    }
  }
} 