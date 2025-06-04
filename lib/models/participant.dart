// lib/models/participant.dart
import 'package:challengeaccepted/models/user.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';

class Participant {
  final String id;
  final User user;
  final ParticipantRole role;
  final double progress;
  final ParticipantStatus status;
  final DateTime? joinedAt;
  final int dailyStreak;
  final DateTime? lastPostDate;
  final int? restDays;
  final int totalPoints;
  final int weeklyRestDaysUsed;
  final DateTime? lastLogDate;
  final bool isCurrentUser;

  const Participant({
    required this.id,
    required this.user,
    required this.role,
    required this.progress,
    required this.status,
    this.joinedAt,
    required this.dailyStreak,
    this.lastPostDate,
    this.restDays,
    required this.totalPoints,
    required this.weeklyRestDaysUsed,
    this.lastLogDate,
    required this.isCurrentUser,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      role: ParticipantRole.fromString(json['role'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: ParticipantStatus.fromString(json['status'] as String),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      lastPostDate: json['lastPostDate'] != null
          ? DateTime.parse(json['lastPostDate'] as String)
          : null,
      restDays: json['restDays'] as int?,
      totalPoints: json['totalPoints'] as int? ?? 0,
      weeklyRestDaysUsed: json['weeklyRestDaysUsed'] as int? ?? 0,
      lastLogDate: json['lastLogDate'] != null
          ? DateTime.parse(json['lastLogDate'] as String)
          : null,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'role': role.value,
      'progress': progress,
      'status': status.value,
      'joinedAt': joinedAt?.toIso8601String(),
      'dailyStreak': dailyStreak,
      'lastPostDate': lastPostDate?.toIso8601String(),
      'restDays': restDays,
      'totalPoints': totalPoints,
      'weeklyRestDaysUsed': weeklyRestDaysUsed,
      'lastLogDate': lastLogDate?.toIso8601String(),
      'isCurrentUser': isCurrentUser,
    };
  }

  // Computed properties
  bool get canTakeRestDay {
    final allowedRestDays = restDays ?? 1;
    return weeklyRestDaysUsed < allowedRestDays;
  }

  bool get isCreator => role == ParticipantRole.creator;
  bool get isAccepted => status == ParticipantStatus.accepted;
  bool get isPending => status == ParticipantStatus.pending;
}
