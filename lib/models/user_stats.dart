// lib/models/user_stats.dart
import 'package:challengeaccepted/models/active_challenge_info.dart';

class UserStats {
  final int currentStreak;
  final int totalPoints;
  final int completedChallenges;
  final ActiveChallengeInfo? activeChallenge;

  const UserStats({
    required this.currentStreak,
    required this.totalPoints,
    required this.completedChallenges,
    this.activeChallenge,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['currentStreak'] as int,
      totalPoints: json['totalPoints'] as int,
      completedChallenges: json['completedChallenges'] as int,
      activeChallenge: json['activeChallenge'] != null
          ? ActiveChallengeInfo.fromJson(json['activeChallenge'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'totalPoints': totalPoints,
      'completedChallenges': completedChallenges,
      'activeChallenge': activeChallenge?.toJson(),
    };
  }
}