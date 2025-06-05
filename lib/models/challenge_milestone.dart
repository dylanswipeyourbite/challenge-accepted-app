class ChallengeMilestone {
  final String id;
  final String title;
  final String description;
  final String type; // points, streak, activities, custom
  final int targetValue;
  final String icon;
  final String? reward;
  final List<MilestoneAchievement> achievedBy;
  final DateTime createdAt;
  
  ChallengeMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.icon,
    this.reward,
    this.achievedBy = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'targetValue': targetValue,
      'icon': icon,
      'reward': reward,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory ChallengeMilestone.fromJson(Map<String, dynamic> json) {
    return ChallengeMilestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      targetValue: json['targetValue'],
      icon: json['icon'],
      reward: json['reward'],
      achievedBy: (json['achievedBy'] as List<dynamic>?)
          ?.map((a) => MilestoneAchievement.fromJson(a))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MilestoneAchievement {
  final String userId;
  final DateTime achievedAt;
  
  MilestoneAchievement({
    required this.userId,
    required this.achievedAt,
  });
  
  factory MilestoneAchievement.fromJson(Map<String, dynamic> json) {
    return MilestoneAchievement(
      userId: json['userId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}