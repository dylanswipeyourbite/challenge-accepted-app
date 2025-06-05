// lib/models/today_status.dart
import 'package:challengeaccepted/models/participant_daily_status.dart';

class TodayStatus {
  final bool allParticipantsLogged;
  final int participantsLoggedCount;
  final int totalParticipants;
  final List<ParticipantDailyStatus> participantsStatus;

  const TodayStatus({
    required this.allParticipantsLogged,
    required this.participantsLoggedCount,
    required this.totalParticipants,
    required this.participantsStatus,
  });

  factory TodayStatus.fromJson(Map<String, dynamic> json) {
    return TodayStatus(
      allParticipantsLogged: json['allParticipantsLogged'] as bool? ?? false,
      participantsLoggedCount: json['participantsLoggedCount'] as int? ?? 0,
      totalParticipants: json['totalParticipants'] as int? ?? 0,
      participantsStatus: (json['participantsStatus'] as List<dynamic>?)
          ?.map((p) => ParticipantDailyStatus.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allParticipantsLogged': allParticipantsLogged,
      'participantsLoggedCount': participantsLoggedCount,
      'totalParticipants': totalParticipants,
      'participantsStatus': participantsStatus.map((p) => p.toJson()).toList(),
    };
  }

  // Computed properties
  double get progressPercentage {
    if (totalParticipants == 0) return 0.0;
    return participantsLoggedCount / totalParticipants;
  }

  bool get hasCurrentUserLogged {
    try {
      final userStatus = participantsStatus.firstWhere(
        (status) => status.participant.isCurrentUser,
      );
      return userStatus.hasLoggedToday;
    } catch (_) {
      return false;
    }
  }
}