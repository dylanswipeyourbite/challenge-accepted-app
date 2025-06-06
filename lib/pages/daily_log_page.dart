// lib/pages/daily_log_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/widgets/forms/daily_log_form.dart';
import 'package:challengeaccepted/widgets/cards/streak_display_card.dart';
import 'package:challengeaccepted/widgets/cards/rest_day_info_card.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';

// Provider-aware version that doesn't need props passed in
class ProviderAwareDailyLogPage extends StatelessWidget {
  final String challengeId;
  final bool isMultiChallenge;
  final String? challengeProgress;
  final VoidCallback? onComplete;

  const ProviderAwareDailyLogPage({
    super.key,
    required this.challengeId,
    this.isMultiChallenge = false,
    this.challengeProgress,
    this.onComplete,
  });

  void _handleCompletion(BuildContext context) async {
    // Store providers before any navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    // Return true to indicate successful logging
    Navigator.of(context).pop(true);
    
    // If there's an external onComplete callback, call it
    onComplete?.call();
    
    // Refresh providers after navigation is complete
    await Future.delayed(const Duration(milliseconds: 100));
    await Future.wait([
      challengeProvider.refresh(),
      userActivityProvider.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        final userParticipant = provider.getCurrentUserParticipant(challengeId);

        if (challenge == null || userParticipant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Log Activity')),
            body: ErrorMessage(
              message: challenge == null
                  ? 'Challenge not found'
                  : 'You are not a participant in this challenge',
              showRetry: false,
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        final allowedRestDays = userParticipant.restDays ?? 1;
        final usedRestDays = userParticipant.weeklyRestDaysUsed;
        final currentStreak = userParticipant.dailyStreak;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Today - ${challenge.title}'),
                if (isMultiChallenge && challengeProgress != null)
                  Text(
                    'Challenge $challengeProgress',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreakDisplayCard(currentStreak: currentStreak),
                const SizedBox(height: 24),
                RestDayInfoCard(
                  usedRestDays: usedRestDays,
                  allowedRestDays: allowedRestDays,
                ),
                const SizedBox(height: 24),
                RefactoredDailyLogForm(
                  challengeId: challengeId,
                  challengeTitle: challenge.title,
                  canTakeRestDay: usedRestDays < allowedRestDays,
                  onComplete: () => _handleCompletion(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}