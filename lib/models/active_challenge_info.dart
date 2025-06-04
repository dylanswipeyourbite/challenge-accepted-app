// lib/models/active_challenge_info.dart
class ActiveChallengeInfo {
  final String id;
  final String title;
  final int allowedRestDays;
  final int usedRestDaysThisWeek;
  final bool hasLoggedToday;

  const ActiveChallengeInfo({
    required this.id,
    required this.title,
    required this.allowedRestDays,
    required this.usedRestDaysThisWeek,
    required this.hasLoggedToday,
  });

  factory ActiveChallengeInfo.fromJson(Map<String, dynamic> json) {
    return ActiveChallengeInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      allowedRestDays: json['allowedRestDays'] as int,
      usedRestDaysThisWeek: json['usedRestDaysThisWeek'] as int,
      hasLoggedToday: json['hasLoggedToday'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'allowedRestDays': allowedRestDays,
      'usedRestDaysThisWeek': usedRestDaysThisWeek,
      'hasLoggedToday': hasLoggedToday,
    };
  }

  int get remainingRestDays => allowedRestDays - usedRestDaysThisWeek;
  bool get canTakeRestDay => remainingRestDays > 0;
}