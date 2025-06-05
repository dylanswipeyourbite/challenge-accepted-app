// File: lib/services/gamification_service.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/badge.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();
  
  // Badge definitions
  static final List<BadgeDefinition> badges = [
    BadgeDefinition(
      id: 'first_step',
      name: 'First Step',
      description: 'Complete your first activity',
      icon: '👟',
      category: BadgeCategory.milestone,
      criteria: BadgeCriteria(type: 'activities', value: 1),
    ),
    BadgeDefinition(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      category: BadgeCategory.streak,
      criteria: BadgeCriteria(type: 'streak', value: 7),
    ),
    BadgeDefinition(
      id: 'century_club',
      name: 'Century Club',
      description: 'Earn 100 points in a single challenge',
      icon: '💯',
      category: BadgeCategory.points,
      criteria: BadgeCriteria(type: 'points', value: 100),
    ),
    BadgeDefinition(
      id: 'social_butterfly',
      name: 'Social Butterfly',
      description: 'Cheer 50 posts',
      icon: '🦋',
      category: BadgeCategory.social,
      criteria: BadgeCriteria(type: 'cheers', value: 50),
    ),
    BadgeDefinition(
      id: 'iron_will',
      name: 'Iron Will',
      description: 'Complete a 30-day streak',
      icon: '🏆',
      category: BadgeCategory.streak,
      criteria: BadgeCriteria(type: 'streak', value: 30),
    ),
    BadgeDefinition(
      id: 'team_player',
      name: 'Team Player',
      description: 'Help your team achieve a 7-day collective streak',
      icon: '🤝',
      category: BadgeCategory.social,
      criteria: BadgeCriteria(type: 'team_streak', value: 7),
    ),
    BadgeDefinition(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Log 10 activities before 9 AM',
      icon: '🌅',
      category: BadgeCategory.special,
      criteria: BadgeCriteria(type: 'early_logs', value: 10),
    ),
    BadgeDefinition(
      id: 'rest_master',
      name: 'Rest Master',
      description: 'Use all your rest days wisely for 4 weeks',
      icon: '😴',
      category: BadgeCategory.special,
      criteria: BadgeCriteria(type: 'rest_optimization', value: 4),
    ),
  ];
  
  // GraphQL client for badge operations
  GraphQLClient? _client;
  
  void setClient(GraphQLClient client) {
    _client = client;
  }
  
  // Check for new badges earned
  Future<List<BadgeEarned>> checkBadges({
    required String userId,
    required int currentStreak,
    required int totalPoints,
    required int totalActivities,
    required List<String> existingBadgeIds,
    int? totalCheers,
    int? earlyLogs,
    int? teamStreak,
    int? restWeeksOptimized,
  }) async {
    final List<BadgeEarned> newBadges = [];
    
    for (final badge in badges) {
      if (existingBadgeIds.contains(badge.id)) continue;
      
      bool earned = false;
      
      switch (badge.criteria.type) {
        case 'streak':
          if (currentStreak >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'points':
          if (totalPoints >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'activities':
          if (totalActivities >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'cheers':
          if (totalCheers != null && totalCheers >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'team_streak':
          if (teamStreak != null && teamStreak >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'early_logs':
          if (earlyLogs != null && earlyLogs >= badge.criteria.value) {
            earned = true;
          }
          break;
          
        case 'rest_optimization':
          if (restWeeksOptimized != null && restWeeksOptimized >= badge.criteria.value) {
            earned = true;
          }
          break;
      }
      
      if (earned) {
        final earnedBadge = BadgeEarned(
          badgeId: badge.id,
          userId: userId,
          earnedAt: DateTime.now(),
          badge: badge,
        );
        newBadges.add(earnedBadge);
        
        // Award badge via GraphQL mutation
        await _awardBadge(userId, badge.id);
      }
    }
    
    return newBadges;
  }
  
  // Get next achievable badges
  Future<List<BadgeProgress>> getNextBadges({
    required String userId,
    required int currentStreak,
    required int totalPoints,
    required int totalActivities,
    required List<String> existingBadgeIds,
    int? totalCheers,
    int? earlyLogs,
    int? teamStreak,
    int? restWeeksOptimized,
  }) async {
    final List<BadgeProgress> nextBadges = [];
    
    for (final badge in badges) {
      if (existingBadgeIds.contains(badge.id)) continue;
      
      int currentValue = 0;
      double progress = 0.0;
      
      switch (badge.criteria.type) {
        case 'streak':
          currentValue = currentStreak;
          progress = currentStreak / badge.criteria.value;
          break;
          
        case 'points':
          currentValue = totalPoints;
          progress = totalPoints / badge.criteria.value;
          break;
          
        case 'activities':
          currentValue = totalActivities;
          progress = totalActivities / badge.criteria.value;
          break;
          
        case 'cheers':
          if (totalCheers != null) {
            currentValue = totalCheers;
            progress = totalCheers / badge.criteria.value;
          }
          break;
          
        case 'team_streak':
          if (teamStreak != null) {
            currentValue = teamStreak;
            progress = teamStreak / badge.criteria.value;
          }
          break;
          
        case 'early_logs':
          if (earlyLogs != null) {
            currentValue = earlyLogs;
            progress = earlyLogs / badge.criteria.value;
          }
          break;
          
        case 'rest_optimization':
          if (restWeeksOptimized != null) {
            currentValue = restWeeksOptimized;
            progress = restWeeksOptimized / badge.criteria.value;
          }
          break;
      }
      
      if (progress > 0 && progress < 1) {
        nextBadges.add(BadgeProgress(
          badge: badge,
          currentValue: currentValue,
          targetValue: badge.criteria.value,
          progress: progress,
        ));
      }
    }
    
    // Sort by closest to completion
    nextBadges.sort((a, b) => b.progress.compareTo(a.progress));
    
    return nextBadges.take(3).toList();
  }
  
  // Award badge mutation
  Future<void> _awardBadge(String userId, String badgeType) async {
    if (_client == null) return;
    
    const String awardBadgeMutation = """
      mutation AwardBadge(\$userId: ID!, \$badgeType: String!) {
        awardBadge(userId: \$userId, badgeType: \$badgeType) {
          badge {
            id
            name
          }
          earnedAt
        }
      }
    """;
    
    try {
      await _client!.mutate(
        MutationOptions(
          document: gql(awardBadgeMutation),
          variables: {
            'userId': userId,
            'badgeType': badgeType,
          },
        ),
      );
    } catch (e) {
      debugPrint('Error awarding badge: $e');
    }
  }
  
  // Get user's badges
  Future<List<BadgeEarned>> getUserBadges(String userId) async {
    if (_client == null) return [];
    
    const String getUserBadgesQuery = """
      query GetUserBadges(\$userId: ID!) {
        userBadges(userId: \$userId) {
          badge {
            id
            type
            name
            description
            icon
            category
          }
          earnedAt
        }
      }
    """;
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(getUserBadgesQuery),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        debugPrint('Error fetching user badges: ${result.exception}');
        return [];
      }
      
      final badgesData = result.data?['userBadges'] as List? ?? [];
      
      return badgesData.map((data) {
        final badgeData = data['badge'] as Map<String, dynamic>;
        final badge = badges.firstWhere(
          (b) => b.id == badgeData['type'],
          orElse: () => BadgeDefinition(
            id: badgeData['type'],
            name: badgeData['name'],
            description: badgeData['description'],
            icon: badgeData['icon'],
            category: BadgeCategory.values.firstWhere(
              (c) => c.name == badgeData['category'],
              orElse: () => BadgeCategory.special,
            ),
            criteria: BadgeCriteria(type: '', value: 0),
          ),
        );
        
        return BadgeEarned(
          badgeId: badge.id,
          userId: userId,
          earnedAt: DateTime.parse(data['earnedAt']),
          badge: badge,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error parsing user badges: $e');
      return [];
    }
  }
  
  // Check if user has specific badge
  Future<bool> hasBadge(String userId, String badgeId) async {
    final userBadges = await getUserBadges(userId);
    return userBadges.any((badge) => badge.badgeId == badgeId);
  }
  
  // Get badge by ID
  BadgeDefinition? getBadgeById(String badgeId) {
    try {
      return badges.firstWhere((badge) => badge.id == badgeId);
    } catch (e) {
      return null;
    }
  }
  
  // Calculate total cheers given by user
  Future<int> getTotalCheersGiven(String userId) async {
    // This would typically come from a GraphQL query
    // For now, returning a placeholder
    return 0;
  }
  
  // Calculate early morning logs
  Future<int> getEarlyMorningLogs(String userId) async {
    // This would check logs before 9 AM
    // For now, returning a placeholder
    return 0;
  }
  
  // Check team streak for collaborative challenges
  Future<int> getTeamStreak(String challengeId) async {
    // This would check the challenge's collective streak
    // For now, returning a placeholder
    return 0;
  }
  
  // Check rest day optimization
  Future<int> getRestWeeksOptimized(String userId) async {
    // This would check if user used rest days optimally
    // For now, returning a placeholder
    return 0;
  }
  
  // Get all available badges
  List<BadgeDefinition> getAllBadges() {
    return List.unmodifiable(badges);
  }
  
  // Get badges by category
  List<BadgeDefinition> getBadgesByCategory(BadgeCategory category) {
    return badges.where((badge) => badge.category == category).toList();
  }
  
  // Calculate overall progress
  double calculateOverallProgress({
    required String userId,
    required List<BadgeEarned> earnedBadges,
  }) {
    if (badges.isEmpty) return 0.0;
    return earnedBadges.length / badges.length;
  }
  
  // Get badge rarity (percentage of users who have it)
  Future<double> getBadgeRarity(String badgeId) async {
    // This would query the backend for statistics
    // For now, returning a mock value
    switch (badgeId) {
      case 'first_step':
        return 0.9; // 90% have it
      case 'week_warrior':
        return 0.5; // 50% have it
      case 'iron_will':
        return 0.1; // 10% have it
      default:
        return 0.3; // 30% default
    }
  }
}