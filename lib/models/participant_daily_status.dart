// lib/models/participant_daily_status.dart
import 'package:challengeaccepted/models/participant.dart';

class ParticipantDailyStatus {
  final Participant participant;
  final bool hasLoggedToday;
  final DateTime? lastLogTime;

  const ParticipantDailyStatus({
    required this.participant,
    required this.hasLoggedToday,
    this.lastLogTime,
  });

  factory ParticipantDailyStatus.fromJson(Map<String, dynamic> json) {
    return ParticipantDailyStatus(
      participant: Participant.fromJson(json['participant'] as Map<String, dynamic>? ?? {}),
      hasLoggedToday: json['hasLoggedToday'] as bool? ?? false,
      lastLogTime: json['lastLogTime'] != null
          ? DateTime.parse(json['lastLogTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'hasLoggedToday': hasLoggedToday,
      'lastLogTime': lastLogTime?.toIso8601String(),
    };
  }

  String get timeSinceLog {
    if (lastLogTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(lastLogTime!);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '';
  }
}