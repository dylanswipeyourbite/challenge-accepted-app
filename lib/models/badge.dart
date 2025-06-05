enum BadgeCategory {
  milestone,
  streak,
  points,
  social,
  special,
}

class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeCriteria criteria;
  
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.criteria,
  });
}

class BadgeCriteria {
  final String type;
  final int value;
  
  const BadgeCriteria({
    required this.type,
    required this.value,
  });
}

class BadgeEarned {
  final String badgeId;
  final String userId;
  final DateTime earnedAt;
  final BadgeDefinition badge;
  
  const BadgeEarned({
    required this.badgeId,
    required this.userId,
    required this.earnedAt,
    required this.badge,
  });
}

class BadgeProgress {
  final BadgeDefinition badge;
  final int currentValue;
  final int targetValue;
  final double progress;
  
  const BadgeProgress({
    required this.badge,
    required this.currentValue,
    required this.targetValue,
    required this.progress,
  });
}