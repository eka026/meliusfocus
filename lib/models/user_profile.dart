import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String language;
  final int xp;
  /// photoUrl now stores a base64-encoded image string, not a URL.
  final String? photoUrl;
  final int streak;
  final int maxSessionDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? themeMode;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.language = 'English',
    this.xp = 0,
    this.photoUrl,
    this.streak = 0,
    this.maxSessionDuration = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    this.themeMode,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now(),
    this.createdBy = createdBy ?? uid;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'language': language,
      'xp': xp,
      'photoUrl': photoUrl,
      'streak': streak,
      'maxSessionDuration': maxSessionDuration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'themeMode': themeMode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      language: map['language'] ?? 'English',
      xp: map['xp'] ?? 0,
      photoUrl: map['photoUrl'],
      streak: map['streak'] ?? 0,
      maxSessionDuration: map['maxSessionDuration'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? map['uid'] ?? '',
      themeMode: map['themeMode'],
    );
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? language,
    int? xp,
    String? photoUrl,
    int? streak,
    int? maxSessionDuration,
    String? themeMode,
  }) {
    return UserProfile(
      uid: this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      language: language ?? this.language,
      xp: xp ?? this.xp,
      photoUrl: photoUrl ?? this.photoUrl,
      streak: streak ?? this.streak,
      maxSessionDuration: maxSessionDuration ?? this.maxSessionDuration,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      createdBy: this.createdBy,
      themeMode: themeMode ?? this.themeMode,
    );
  }
} 