// lib/widgets/dialogs/activity_success_dialog.dart
// Update to use the enhanced version with proper badge checking

import 'package:challengeaccepted/models/badge.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/services/gamification_service.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/dialogs/enhanced_success_dialog.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';

class ActivitySuccessDialog extends StatelessWidget {
  final int pointsEarned;
  final int newStreak;
  final String challengeTitle;
  final VoidCallback onComplete;
  final bool isLastChallenge;
  final String? challengeId;

  const ActivitySuccessDialog({
    super.key,
    required this.pointsEarned,
    required this.newStreak,
    required this.challengeTitle,
    required this.onComplete,
    this.isLastChallenge = true,
    this.challengeId,
  });

Future<List<BadgeEarned>> _checkForBadges(BuildContext context) async {
    try {
      // Get the MongoDB user ID from the challenge provider
      final challengeProvider = context.read<ChallengeProvider>();
      final userActivityProvider = context.read<UserActivityProvider>();
      
      // Get the current user's participant info from any active challenge
      final activeChallenges = challengeProvider.activeChallenges;
      if (activeChallenges.isEmpty) return [];
      
      // Find the current user's MongoDB ID from participant data
      final currentUserParticipant = activeChallenges.first.participants
          .firstWhere((p) => p.isCurrentUser, orElse: () => throw Exception('User not found'));
      
      final mongoUserId = currentUserParticipant.user.id;
      
      final gamificationService = GamificationService();
      
      // Get current user badges using MongoDB ID
      final userBadges = await gamificationService.getUserBadges(mongoUserId);
      final existingBadgeIds = userBadges.map((b) => b.badgeId).toList();
      
      // Get total points from provider
      final totalPoints = userActivityProvider.totalPoints;
      
      // Check for new badges based on the activity
      final newBadges = await gamificationService.checkBadges(
        userId: mongoUserId,
        currentStreak: newStreak,
        totalPoints: totalPoints,
        totalActivities: 1,
        existingBadgeIds: existingBadgeIds,
      );
      
      return newBadges;
    } catch (e) {
      print('Error checking for badges: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the enhanced dialog with proper badge checking
    return FutureBuilder<List<BadgeEarned>>(
      future: _checkForBadges(context),
      builder: (context, snapshot) {
        final newBadges = snapshot.data ?? [];
        
        return EnhancedSuccessDialog(
          pointsEarned: pointsEarned,
          newStreak: newStreak,
          challengeTitle: challengeTitle,
          newBadges: newBadges.isNotEmpty ? newBadges : null,
          milestone: null, // TODO: Check for milestone achievements
          onComplete: onComplete,
          onShare: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon!'),
              ),
            );
          },
        );
      },
    );
  }
}