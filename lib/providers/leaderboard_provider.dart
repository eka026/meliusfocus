import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TimeFrame { week, month, allTime }

class LeaderboardUser {
  final String uid;
  final String name;
  final int xp;
  final DateTime? lastStudiedAt;
  final String? photoUrl;

  LeaderboardUser({
    required this.uid,
    required this.name,
    required this.xp,
    this.lastStudiedAt,
    this.photoUrl,
  });

  factory LeaderboardUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardUser(
      uid: doc.id,
      name: data['username'] ?? 'Anonymous User',
      xp: data['xp'] ?? 0,
      lastStudiedAt: (data['lastStudiedAt'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'],
    );
  }
}

class LeaderboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<LeaderboardUser> _users = [];
  TimeFrame _currentTimeFrame = TimeFrame.week;
  bool _isLoading = false;
  String? _error;

  List<LeaderboardUser> get users => _users;
  TimeFrame get currentTimeFrame => _currentTimeFrame;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LeaderboardProvider() {
    fetchLeaderboardData();
  }

  void setTimeFrame(TimeFrame timeFrame) {
    if (_currentTimeFrame != timeFrame) {
      _currentTimeFrame = timeFrame;
      fetchLeaderboardData();
    }
  }

  Future<void> fetchLeaderboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final now = DateTime.now();
      DateTime periodStart;
      switch (_currentTimeFrame) {
        case TimeFrame.week:
          periodStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
          break;
        case TimeFrame.month:
          periodStart = DateTime(now.year, now.month, 1);
          break;
        case TimeFrame.allTime:
          periodStart = DateTime(1970, 1, 1);
          break;
      }
      List<LeaderboardUser> leaderboardUsers = [];
      for (final doc in usersSnapshot.docs) {
        final userId = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        // Fetch XP logs for the period
        final xpLogsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('xp_log')
            .where('timestamp', isGreaterThanOrEqualTo: periodStart)
            .get();
        int periodXp = xpLogsSnapshot.docs.fold(0, (sum, logDoc) {
          final amount = logDoc['amount'];
          if (amount is int) return sum + amount;
          if (amount is double) return sum + amount.toInt();
          if (amount is num) return sum + amount.toInt();
          return sum;
        });
        if (periodXp > 0) {
          leaderboardUsers.add(LeaderboardUser(
            uid: userId,
            name: data['username'] ?? 'Anonymous User',
            xp: periodXp,
            lastStudiedAt: (data['lastStudiedAt'] as Timestamp?)?.toDate(),
            photoUrl: data['photoUrl'],
          ));
        }
      }
      leaderboardUsers.sort((a, b) => b.xp.compareTo(a.xp));
      _users = leaderboardUsers;
    } catch (e) {
      _error = 'Failed to load leaderboard data';
      _users = [];
    }
    _isLoading = false;
    notifyListeners();
  }
} 