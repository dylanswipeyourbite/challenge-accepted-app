// lib/models/challenge_enums.dart
import 'package:flutter/material.dart';

enum SportType {
  running('running'),
  cycling('cycling'),
  workout('workout');

  final String value;
  const SportType(this.value);

  static SportType fromString(String value) {
    return SportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SportType.workout,
    );
  }

  IconData get icon {
    switch (this) {
      case SportType.running:
        return Icons.directions_run;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.workout:
        return Icons.fitness_center;
    }
  }

  Color get color {
    switch (this) {
      case SportType.running:
        return Colors.orange;
      case SportType.cycling:
        return Colors.blue;
      case SportType.workout:
        return Colors.purple;
    }
  }
}

enum ChallengeType {
  competitive('competitive'),
  collaborative('collaborative');

  final String value;
  const ChallengeType(this.value);

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChallengeType.competitive,
    );
  }

  IconData get icon {
    switch (this) {
      case ChallengeType.competitive:
        return Icons.emoji_events;
      case ChallengeType.collaborative:
        return Icons.group;
    }
  }
}

enum ChallengeStatus {
  pending('pending'),
  active('active'),
  completed('completed'),
  expired('expired');

  final String value;
  const ChallengeStatus(this.value);

  static ChallengeStatus fromString(String value) {
    return ChallengeStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChallengeStatus.pending,
    );
  }
}

enum ParticipantRole {
  creator('creator'),
  admin('admin'),
  participant('participant'),
  spectator('spectator');

  final String value;
  const ParticipantRole(this.value);

  static ParticipantRole fromString(String value) {
    return ParticipantRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParticipantRole.participant,
    );
  }
}

enum ParticipantStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  completed('completed');

  final String value;
  const ParticipantStatus(this.value);

  static ParticipantStatus fromString(String value) {
    return ParticipantStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParticipantStatus.pending,
    );
  }
}

enum LogType {
  activity('activity'),
  rest('rest');

  final String value;
  const LogType(this.value);

  static LogType fromString(String value) {
    return LogType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LogType.activity,
    );
  }
}

enum ActivityType {
  running('running'),
  cycling('cycling'),
  workout('workout'),
  other('other');

  final String value;
  const ActivityType(this.value);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityType.other,
    );
  }
}