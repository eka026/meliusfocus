import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FocusState { initial, running, paused, breakTime }

class FocusModeProvider with ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  String _mode = 'Pomodoro';

  DateTime? _sessionStartTime;
  int _completedFocusSecondsThisSession = 0;

  static const int XP_PER_MINUTE_STUDIED = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isBreak => _isBreak;
  String get mode => _mode;
  String get formattedTime => _formatTime(_remainingSeconds);
  String get currentPhaseText => _mode == 'Pomodoro'
      ? (_isBreak ? 'Break Time 🍵' : 'Focus Time 📚')
      : 'Focus Time 📚';

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  void clearFeedbackMessage() {
    _feedbackMessage = null;
  }

  FocusModeProvider() {
    _resetTimerValues();
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void setMode(String selectedMode) {
    if (_isRunning && !_isBreak && _sessionStartTime != null) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
    }
    _mode = selectedMode;
    _isBreak = false;
    // Corrected: Call the public resetTimer() method
    resetTimer(); // This will also clear session tracking and notify
    notifyListeners(); // Ensure UI updates for mode change if resetTimer doesn't cover it immediately
  }

  void _resetTimerValues() {
    if (_mode == 'Pomodoro') {
      _remainingSeconds = _isBreak ? 5 * 60 : 25 * 60;
    } else {
      _remainingSeconds = 50 * 60;
    }
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    if (!_isBreak && _sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
      _completedFocusSecondsThisSession = 0;
    }
    notifyListeners();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        if (!_isBreak && _isRunning) {
          _completedFocusSecondsThisSession++;
        }
      } else {
        timer.cancel();
        bool wasFocusSession = !_isBreak;
        _isRunning = false;

        if (wasFocusSession && _sessionStartTime != null) {
          _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
          _clearSessionTracking();
        }

        if (_mode == 'Pomodoro') {
          _isBreak = !_isBreak;
          _resetTimerValues();
          startTimer();
        } else {
          _resetTimerValues();
        }
      }
      notifyListeners();
    });
  }

  void stopTimer() {
    if (!_isRunning) return;

    if (!_isBreak && _sessionStartTime != null) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
    }
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // Public method to reset the timer fully
  void resetTimer() {
    if (_isRunning && !_isBreak && _sessionStartTime != null) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
    }
    _timer?.cancel();
    _isRunning = false;
    _clearSessionTracking();
    _resetTimerValues();
    notifyListeners();
  }

  void _clearSessionTracking() {
    _sessionStartTime = null;
    _completedFocusSecondsThisSession = 0;
  }

  void _awardXpForCompletedDuration(int studiedSeconds) {
    if (studiedSeconds <= 0) return;

    int minutesStudied = (studiedSeconds / 60).floor();
    if (minutesStudied > 0) {
      int xpEarned = minutesStudied * XP_PER_MINUTE_STUDIED;
      _updateUserXp(xpEarned);
    }
    _completedFocusSecondsThisSession = 0;
  }

  Future<void> _updateUserXp(int xpToAdd) async {
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
      await userDocRef.set({
        'xp': FieldValue.increment(xpToAdd),
        'lastStudiedAt': FieldValue.serverTimestamp(),
        'uid': currentUser.uid,
      }, SetOptions(merge: true));
      _feedbackMessage = '🎉 You earned $xpToAdd XP! Keep focusing!';
    } catch (e) {
      _feedbackMessage = 'Error updating XP: ${e.toString()}';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isRunning && !_isBreak && _sessionStartTime != null) {
      _awardXpForCompletedDuration(_completedFocusSecondsThisSession);
    }
    _timer?.cancel();
    super.dispose();
  }
}