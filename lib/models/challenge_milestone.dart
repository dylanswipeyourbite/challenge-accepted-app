// models/challenge_milestone.dart

class ChallengeMilestone {
  final String id;
  final String name;
  final String type; // 'points', 'streak', 'activities', 'custom'
  final int target;
  final String? description;
  final DateTime? deadline;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<MilestoneAchievement> achievedBy; 

  ChallengeMilestone({
    required this.id,
    required this.name,
    required this.type,
    required this.target,
    this.description,
    this.deadline,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
    this.achievedBy = const [],
  });

  // Factory constructor for creating from Map (e.g., from Firestore)
  // Update factory constructor:
  factory ChallengeMilestone.fromMap(Map<String, dynamic> map) {
    return ChallengeMilestone(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'points',
      target: map['target'] ?? 0,
      description: map['description'],
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      currentProgress: map['currentProgress'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      achievedBy: (map['achievedBy'] as List<dynamic>?)
          ?.map((achievement) => MilestoneAchievement.fromMap(achievement))
          .toList() ?? [],  // Add this
    );
  }

  // Convert to Map for Firestore
  // In challenge_milestone.dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'target': target,  // Make sure backend expects 'target' not 'targetValue'
      'description': description,
    };
  }

  ChallengeMilestone copyWith({
    String? id,
    String? name,
    String? type,
    int? target,
    String? description,
    DateTime? deadline,
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
    List<MilestoneAchievement>? achievedBy,  // Add this
  }) {
    return ChallengeMilestone(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      target: target ?? this.target,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      achievedBy: achievedBy ?? this.achievedBy,  // Add this
    );
  }

  // Helper method to get progress percentage
  double get progressPercentage {
    if (target == 0) return 0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  // Helper method to check if milestone is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }
}

// Add this new class for milestone achievements:
class MilestoneAchievement {
  final String userId;
  final DateTime achievedAt;
  final int? value;  // For progress-based milestones

  const MilestoneAchievement({
    required this.userId,
    required this.achievedAt,
    this.value,
  });

  factory MilestoneAchievement.fromMap(Map<String, dynamic> map) {
    return MilestoneAchievement(
      userId: map['userId'] ?? '',
      achievedAt: DateTime.parse(map['achievedAt']),
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'achievedAt': achievedAt.toIso8601String(),
      if (value != null) 'value': value,
    };
  }
}