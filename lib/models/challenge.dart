// lib/models/challenge.dart
import 'package:challengeaccepted/models/participant.dart';
import 'package:challengeaccepted/models/user.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:challengeaccepted/models/today_status.dart';

class Challenge {
  final String id;
  final String title;
  final SportType sport;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime timeLimit;
  final String? wager;
  final User createdBy;
  final List<Participant> participants;
  final DateTime createdAt;
  final ChallengeStatus status;
  final int challengeStreak;
  final DateTime? lastCompleteLogDate;
  final TodayStatus? todayStatus;

  const Challenge({
    required this.id,
    required this.title,
    required this.sport,
    required this.type,
    required this.startDate,
    required this.timeLimit,
    this.wager,
    required this.createdBy,
    required this.participants,
    required this.createdAt,
    required this.status,
    required this.challengeStreak,
    this.lastCompleteLogDate,
    this.todayStatus,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      sport: SportType.fromString(json['sport'] as String? ?? 'gym'),
      type: ChallengeType.fromString(json['type'] as String? ?? 'competitive'),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      timeLimit: json['timeLimit'] != null
          ? DateTime.parse(json['timeLimit'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      wager: json['wager'] as String?,
      createdBy: User.fromJson(json['createdBy'] as Map<String, dynamic>? ?? {}),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      status: ChallengeStatus.fromString(json['status'] as String? ?? 'pending'),
      challengeStreak: json['challengeStreak'] as int? ?? 0,
      lastCompleteLogDate: json['lastCompleteLogDate'] != null
          ? DateTime.parse(json['lastCompleteLogDate'] as String)
          : null,
      todayStatus: json['todayStatus'] != null
          ? TodayStatus.fromJson(json['todayStatus'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sport': sport.value,
      'type': type.value,
      'startDate': startDate.toIso8601String(),
      'timeLimit': timeLimit.toIso8601String(),
      'wager': wager,
      'createdBy': createdBy.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.value,
      'challengeStreak': challengeStreak,
      'lastCompleteLogDate': lastCompleteLogDate?.toIso8601String(),
      'todayStatus': todayStatus?.toJson(),
    };
  }

  // Computed properties
  int get daysRemaining {
    final now = DateTime.now();
    return timeLimit.difference(now).inDays;
  }

  bool get isActive => status == ChallengeStatus.active;
  bool get isPending => status == ChallengeStatus.pending;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isExpired => status == ChallengeStatus.expired;

  int get acceptedParticipantsCount {
    return participants.where((p) => p.status == ParticipantStatus.accepted).length;
  }

  Participant? get currentUserParticipant {
    try {
      return participants.firstWhere((p) => p.isCurrentUser);
    } catch (_) {
      return null;
    }
  }

  bool get hasCurrentUserLogged {
    return todayStatus?.hasCurrentUserLogged ?? false;
  }
}