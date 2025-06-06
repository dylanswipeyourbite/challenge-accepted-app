// lib/services/badge_service_integration.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/services/gamification_service.dart';
import 'package:challengeaccepted/models/badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:challengeaccepted/services/notification_service.dart';

class BadgeServiceIntegration {
  final BuildContext context;
  
  BadgeServiceIntegration(this.context);
  
  GamificationService get _gamificationService => context.read<GamificationService>();
  NotificationService get _notificationService => context.read<NotificationService>();
  
  // Check for new badges after an activity is logged
  Future<List<BadgeEarned>> checkBadgesAfterActivity({
    required int newStreak,
    required int totalPoints,
    required int totalActivities,
    int? teamStreak,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    try {
      // Get current user badges
      final currentBadges = await _gamificationService.getUserBadges(user.uid);
      final existingBadgeIds = currentBadges.map((b) => b.badgeId).toList();
      
      // Get additional stats for special badges
      final totalCheers = await _gamificationService.getTotalCheersGiven(user.uid);
      final earlyLogs = await _gamificationService.getEarlyMorningLogs(user.uid);
      final restWeeksOptimized = await _gamificationService.getRestWeeksOptimized(user.uid);
      
      // Check for new badges
      final newBadges = await _gamificationService.checkBadges(
        userId: user.uid,
        currentStreak: newStreak,
        totalPoints: totalPoints,
        totalActivities: totalActivities,
        existingBadgeIds: existingBadgeIds,
        totalCheers: totalCheers,
        earlyLogs: earlyLogs,
        teamStreak: teamStreak,
        restWeeksOptimized: restWeeksOptimized,
      );
      
      // Send notifications for new badges
      for (final badge in newBadges) {
        await _notificationService.sendMilestoneAchieved(
          badge.badge.name,
          'Badge Earned!',
        );
      }
      
      return newBadges;
    } catch (e) {
      debugPrint('Error checking badges: $e');
      return [];
    }
  }
  
  // Get user's badge progress
  Future<BadgeProgressData> getUserBadgeProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return BadgeProgressData(
        earnedBadges: [],
        nextBadges: [],
        totalProgress: 0.0,
      );
    }
    
    try {
      // Get earned badges
      final earnedBadges = await _gamificationService.getUserBadges(user.uid);
      
      // Get next achievable badges
      final existingBadgeIds = earnedBadges.map((b) => b.badgeId).toList();
      
      // Get current stats (would need to get from providers)
      final currentStreak = 0; // TODO: Get from provider
      final totalPoints = 0; // TODO: Get from provider
      final totalActivities = 0; // TODO: Get from provider
      
      final nextBadges = await _gamificationService.getNextBadges(
        userId: user.uid,
        currentStreak: currentStreak,
        totalPoints: totalPoints,
        totalActivities: totalActivities,
        existingBadgeIds: existingBadgeIds,
      );
      
      // Calculate overall progress
      final totalProgress = _gamificationService.calculateOverallProgress(
        userId: user.uid,
        earnedBadges: earnedBadges,
      );
      
      return BadgeProgressData(
        earnedBadges: earnedBadges,
        nextBadges: nextBadges,
        totalProgress: totalProgress,
      );
    } catch (e) {
      debugPrint('Error getting badge progress: $e');
      return BadgeProgressData(
        earnedBadges: [],
        nextBadges: [],
        totalProgress: 0.0,
      );
    }
  }
  
  // Get badge rarity
  Future<Map<String, double>> getBadgeRarities(List<String> badgeIds) async {
    final rarities = <String, double>{};
    
    for (final badgeId in badgeIds) {
      rarities[badgeId] = await _gamificationService.getBadgeRarity(badgeId);
    }
    
    return rarities;
  }
  
  // Check if user has specific badge
  Future<bool> hasBadge(String badgeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return await _gamificationService.hasBadge(user.uid, badgeId);
  }
}

// Data class for badge progress
class BadgeProgressData {
  final List<BadgeEarned> earnedBadges;
  final List<BadgeProgress> nextBadges;
  final double totalProgress;
  
  const BadgeProgressData({
    required this.earnedBadges,
    required this.nextBadges,
    required this.totalProgress,
  });
}

// Extension to easily access badge service from context
extension BadgeServiceExtension on BuildContext {
  BadgeServiceIntegration get badgeService => BadgeServiceIntegration(this);
}