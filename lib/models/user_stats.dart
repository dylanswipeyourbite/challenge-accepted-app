// Update lib/models/user_stats.dart to include weekly fields

import 'package:challengeaccepted/models/active_challenge_info.dart';

class UserStats {
  final int currentStreak;
  final int totalPoints;
  final int completedChallenges;
  final ActiveChallengeInfo? activeChallenge;
  // Add weekly stats fields
  final int weeklyActivityDays;
  final int weeklyRestDays;
  final int weeklyPoints;

  const UserStats({
    required this.currentStreak,
    required this.totalPoints,
    required this.completedChallenges,
    this.activeChallenge,
    this.weeklyActivityDays = 0,
    this.weeklyRestDays = 0,
    this.weeklyPoints = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      completedChallenges: json['completedChallenges'] as int? ?? 0,
      activeChallenge: json['activeChallenge'] != null
          ? ActiveChallengeInfo.fromJson(json['activeChallenge'] as Map<String, dynamic>)
          : null,
      weeklyActivityDays: json['weeklyActivityDays'] as int? ?? 0,
      weeklyRestDays: json['weeklyRestDays'] as int? ?? 0,
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'totalPoints': totalPoints,
      'completedChallenges': completedChallenges,
      'activeChallenge': activeChallenge?.toJson(),
      'weeklyActivityDays': weeklyActivityDays,
      'weeklyRestDays': weeklyRestDays,
      'weeklyPoints': weeklyPoints,
    };
  }
}