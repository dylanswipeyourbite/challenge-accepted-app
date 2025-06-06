// lib/widgets/dialogs/activity_success_dialog.dart
// Update to use the enhanced version

import 'package:challengeaccepted/models/badge.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/dialogs/enhanced_success_dialog.dart';
import 'package:challengeaccepted/services/gamification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivitySuccessDialog extends StatelessWidget {
  final int pointsEarned;
  final int newStreak;
  final String challengeTitle;
  final VoidCallback onComplete;
  final bool isLastChallenge;

  const ActivitySuccessDialog({
    super.key,
    required this.pointsEarned,
    required this.newStreak,
    required this.challengeTitle,
    required this.onComplete,
    this.isLastChallenge = true,
  });

  Future<List<BadgeEarned>> _checkForBadges() async {
    // Check if user earned any new badges
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    final gamificationService = GamificationService();
    
    // Get current user badges
    final userBadges = await gamificationService.getUserBadges(user.uid);
    final existingBadgeIds = userBadges.map((b) => b.badgeId).toList();
    
    // Check for new badges based on the activity
    final newBadges = await gamificationService.checkBadges(
      userId: user.uid,
      currentStreak: newStreak,
      totalPoints: 0, // Would need to get from provider
      totalActivities: 1,
      existingBadgeIds: existingBadgeIds,
    );
    
    return newBadges;
  }

  @override
  Widget build(BuildContext context) {
    // Use the enhanced dialog instead
    return FutureBuilder<List<BadgeEarned>>(
      future: _checkForBadges(),
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