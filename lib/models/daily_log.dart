// lib/models/daily_log.dart
import 'package:challengeaccepted/models/challenge_enums.dart';

class DailyLog {
  final String id;
  final String challengeId;
  final String participantId;
  final String userId;
  final LogType type;
  final ActivityType? activityType;
  final String? notes;
  final DateTime date;
  final int points;
  final DateTime createdAt;

  const DailyLog({
    required this.id,
    required this.challengeId,
    required this.participantId,
    required this.userId,
    required this.type,
    this.activityType,
    this.notes,
    required this.date,
    required this.points,
    required this.createdAt,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      participantId: json['participantId'] as String,
      userId: json['user'] as String,
      type: LogType.fromString(json['type'] as String),
      activityType: json['activityType'] != null
          ? ActivityType.fromString(json['activityType'] as String)
          : null,
      notes: json['notes'] as String?,
      date: DateTime.parse(json['date'] as String),
      points: json['points'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'participantId': participantId,
      'user': userId,
      'type': type.value,
      'activityType': activityType?.value,
      'notes': notes,
      'date': date.toIso8601String(),
      'points': points,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

