// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    // Listen to auth state changes and update the local _user state
    // This helps in cases where you want to react to user changes immediately within the provider
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Example Sign In method (you'll expand this in your login screen logic)
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // _user will be updated by the stream listener
    } catch (e) {
      // Handle error, perhaps by setting an error message state in the provider
      print(e); // For now, just print
      rethrow; // Rethrow to be caught by the UI if needed
    }
  }

  // Example Sign Up method
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // _user will be updated by the stream listener
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // _user will be updated by the stream listener
  }
}