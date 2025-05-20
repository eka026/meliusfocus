// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserProfile? _userProfile;
  // Optional: to give feedback to the UI during auth operations
  // bool _isLoading = false;

  // Define the getter for 'user' only once
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;

  // Optional:
  // bool get isLoading => _isLoading;

  // Expose the raw stream if needed elsewhere, though typically UI listens to `user`
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _auth.authStateChanges().listen((User? newUser) async {
      print("AuthProvider (authStateChanges listener): Received newUser with UID: ${newUser?.uid}. Current internal _user UID: ${_user?.uid}");
      _user = newUser;
      if (newUser != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      print("AuthProvider (authStateChanges listener): Preparing to notify. Internal _user is now: ${_user?.uid}. Getter authProvider.user will return: ${user?.uid}");
      notifyListeners();
      print("AuthProvider (authStateChanges listener): Just notified.");
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      print("_loadUserProfile: No user found, returning early");
      return;
    }
    
    try {
      print("_loadUserProfile: Starting to load profile for user ${_user!.uid}");
      print("_loadUserProfile: Attempting to access Firestore collection 'users'");
      
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      print("_loadUserProfile: Firestore query completed");
      
      if (doc.exists) {
        print("_loadUserProfile: Document exists with data: ${doc.data()}");
        _userProfile = UserProfile.fromMap(doc.data()!);
        print("_loadUserProfile: UserProfile created successfully");
      } else {
        print("_loadUserProfile: No document found for user ${_user!.uid}");
        // If the document doesn't exist, we should create it
        print("_loadUserProfile: Creating new user profile document");
        final newProfile = UserProfile(
          uid: _user!.uid,
          firstName: _user!.displayName?.split(' ').first ?? '',
          lastName: _user!.displayName?.split(' ').last ?? '',
          username: _user!.email?.split('@').first ?? '',
          email: _user!.email ?? '',
          phoneNumber: _user!.phoneNumber ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: _user!.uid,
        );
        
        await _firestore.collection('users').doc(_user!.uid).set(newProfile.toMap());
        _userProfile = newProfile;
        print("_loadUserProfile: New user profile created and saved");
      }
    } catch (e) {
      print("_loadUserProfile: Error loading user profile: $e");
      print("_loadUserProfile: Error stack trace: ${StackTrace.current}");
    }
  }

  // Modify signInWithEmailAndPassword
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      print("AuthProvider: Attempting Firebase signInWithEmailAndPassword for $email");
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;
      await _loadUserProfile();
      print("AuthProvider (signInMethod): Preparing to notify. Internal _user is now: ${_user?.uid}. Getter authProvider.user will return: ${user?.uid}");
      notifyListeners();
      print("AuthProvider (signInMethod): Just notified.");
      print("AuthProvider: Firebase signInWithEmailAndPassword successful for $email. The authStateChanges listener should now process the new user state.");
    } catch (e) {
      print("AuthProvider: Error in signInWithEmailAndPassword for $email: $e");
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email, 
    String password,
    String firstName,
    String lastName,
    String username,
    String phoneNumber,
  ) async {
    try {
      print("AuthProvider: Attempting Firebase createUserWithEmailAndPassword for $email");
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;

      // Create user profile in Firestore with timestamps
      final userProfile = UserProfile(
        uid: _user!.uid,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _user!.uid,
      );

      await _firestore.collection('users').doc(_user!.uid).set(userProfile.toMap());
      _userProfile = userProfile;

      print("AuthProvider: Firebase createUserWithEmailAndPassword successful for $email. The authStateChanges listener should now process the new user state.");
    } catch (e) {
      print("AuthProvider: Error in signUpWithEmailAndPassword for $email: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print("AuthProvider: Attempting Firebase signOut. Current _user UID: ${_user?.uid}");
      await _auth.signOut();
      _user = null;
      _userProfile = null;
      print("AuthProvider: Firebase signOut successful. User set to null. Notifying listeners.");
      notifyListeners();
    } catch (e) {
      print("AuthProvider: Error in signOut: $e");
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("AuthProvider: Error in sendPasswordResetEmail for $email: $e");
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    if (_user == null) return;

    try {
      print("Updating user profile with data: ${updatedProfile.toMap()}");// Overwrite the whole document to satisfy Firestore rules
      await _firestore.collection('users').doc(_user!.uid).set(
        updatedProfile.toMap(),
        SetOptions(merge: false), // Overwrite the document
      );
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow;
    }
  }

  Future<void> reloadUserProfile() async {
    await _loadUserProfile();
    notifyListeners();
  }
}