import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as local_auth;

class FocusModeProvider with ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // Default 25 minutes
  bool _isRunning = false;
  DateTime? _sessionStartTime;
  int _completedFocusSecondsThisSession = 0;

  static const int XP_PER_MINUTE_STUDIED = 1;
  static const int MIN_TIME_MINUTES = 5;
  static const int MAX_TIME_MINUTES = 120;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int get remainingSeconds => _remainingSeconds;
  int get remainingMinutes => _remainingSeconds ~/ 60;
  bool get isRunning => _isRunning;
  String get formattedTime => _formatTime(_remainingSeconds);

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  void clearFeedbackMessage() {
    _feedbackMessage = null;
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void adjustTime(int minutes) {
    if (_isRunning) return;
    
    int newMinutes = (_remainingSeconds ~/ 60) + minutes;
    if (newMinutes >= MIN_TIME_MINUTES && newMinutes <= MAX_TIME_MINUTES) {
      _remainingSeconds = newMinutes * 60;
      notifyListeners();
    } else {
      _feedbackMessage = 'Timer must be between $MIN_TIME_MINUTES and $MAX_TIME_MINUTES minutes';
      notifyListeners();
    }
  }

  void startTimer(BuildContext context) {
    if (_isRunning) return;

    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _completedFocusSecondsThisSession = 0;
    notifyListeners();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _completedFocusSecondsThisSession++;
      } else {
        timer.cancel();
        _isRunning = false;
        _awardXpForCompletedDuration(_completedFocusSecondsThisSession, context);
        _clearSessionTracking();
      }
      notifyListeners();
    });
  }

  void stopTimer(BuildContext context) {
    if (!_isRunning) return;

    _awardXpForCompletedDuration(_completedFocusSecondsThisSession, context);
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer(BuildContext context) {
    if (_isRunning) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession, context);
    }
    _timer?.cancel();
    _isRunning = false;
    _clearSessionTracking();
    _remainingSeconds = 25 * 60; // Reset to default 25 minutes
    notifyListeners();
  }

  void _clearSessionTracking() {
    _sessionStartTime = null;
    _completedFocusSecondsThisSession = 0;
  }

  void _awardXpForCompletedDuration(int studiedSeconds, [BuildContext? context]) {
    if (studiedSeconds <= 0) return;

    int minutesStudied = (studiedSeconds / 60).floor();
    if (minutesStudied > 0) {
      int xpEarned = minutesStudied * XP_PER_MINUTE_STUDIED;
      _updateUserXp(xpEarned, context);
    }
    _completedFocusSecondsThisSession = 0;
  }

  Future<void> _updateUserXp(int xpToAdd, [BuildContext? context]) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _feedbackMessage = 'You need to be logged in to earn XP!';
      notifyListeners();
      return;
    }
    if (xpToAdd <= 0) {
      _feedbackMessage = 'No XP to add this time.';
      notifyListeners();
      return;
    }

    DocumentReference userDocRef = _firestore.collection('users').doc(currentUser.uid);

    try {
      // Get current user data to check maxSessionDuration and streak
      final userDoc = await userDocRef.get();
      final data = userDoc.data() as Map<String, dynamic>?;
      final currentMaxDuration = data?['maxSessionDuration'] ?? 0;
      final currentStreak = data?['streak'] ?? 0;
      final lastStudiedAt = (data?['lastStudiedAt'] as Timestamp?)?.toDate();
      final currentSessionMinutes = (_completedFocusSecondsThisSession / 60).floor();
      
      // Update maxSessionDuration if current session is longer
      final updates = {
        'xp': FieldValue.increment(xpToAdd),
        'lastStudiedAt': FieldValue.serverTimestamp(),
        'uid': currentUser.uid,
      };
      
      // Update streak if this is the first study session of the day
      final now = DateTime.now();
      if (lastStudiedAt == null || 
          lastStudiedAt.year != now.year || 
          lastStudiedAt.month != now.month || 
          lastStudiedAt.day != now.day) {
        updates['streak'] = currentStreak + 1;
        _feedbackMessage = '🎉 You earned $xpToAdd XP and increased your streak to ${currentStreak + 1} days! Keep focusing!';
      } else {
        _feedbackMessage = '🎉 You earned $xpToAdd XP! Keep focusing!';
      }
      
      if (currentSessionMinutes > currentMaxDuration) {
        updates['maxSessionDuration'] = currentSessionMinutes;
        if (currentSessionMinutes >= 120) {
          _feedbackMessage = '🎉 You earned $xpToAdd XP and unlocked the Focus Beast badge! Keep focusing!';
        }
      }

      await userDocRef.set(updates, SetOptions(merge: true));
      
      // Add XP log entry
      await userDocRef.collection('xp_log').add({
        'amount': xpToAdd,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (context != null) {
        final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
        await authProvider.reloadUserProfile();
      }
    } catch (e) {
      _feedbackMessage = 'Error updating XP: ${e.toString()}';
    }
    notifyListeners();
  }

  void setTime(int minutes) {
    if (_isRunning) return;
    if (minutes >= MIN_TIME_MINUTES && minutes <= MAX_TIME_MINUTES) {
      _remainingSeconds = minutes * 60;
      notifyListeners();
    } else {
      _feedbackMessage = 'Timer must be between $MIN_TIME_MINUTES and $MAX_TIME_MINUTES minutes';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isRunning) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
    }
    _timer?.cancel();
    super.dispose();
  }
}