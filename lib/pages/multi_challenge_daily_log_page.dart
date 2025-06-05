import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/widgets/dialogs/activity_success_dialog.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';
import 'package:challengeaccepted/pages/daily_log_page.dart';

class MultiChallengeDailyLogPage extends StatefulWidget {
  final List<String> challengeIds;

  const MultiChallengeDailyLogPage({
    super.key,
    required this.challengeIds,
  });

  @override
  State<MultiChallengeDailyLogPage> createState() => _MultiChallengeDailyLogPageState();
}

class _MultiChallengeDailyLogPageState extends State<MultiChallengeDailyLogPage> {
  int currentChallengeIndex = 0;
  final Map<String, bool> completedChallenges = {};
  
  // Track accumulated points and highest streak
  int totalPointsEarned = 0;
  int highestStreak = 0;
  String? lastCompletedChallengeTitle;

  void _onChallengeLogged() {
    final currentChallengeId = widget.challengeIds[currentChallengeIndex];
    
    setState(() {
      completedChallenges[currentChallengeId] = true;
      
      if (currentChallengeIndex < widget.challengeIds.length - 1) {
        // Move to next challenge
        currentChallengeIndex++;
      } else {
        // All challenges completed
        _showFinalCompletionDialog();
      }
    });
  }

  void _showFinalCompletionDialog() {
    final provider = context.read<UserActivityProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivitySuccessDialog(
        pointsEarned: provider.weeklyPoints,
        newStreak: provider.currentStreak,
        challengeTitle: '${completedChallenges.length} challenges',
        isLastChallenge: true,
        onComplete: () {
          // Pop until we reach the home page
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.challengeIds.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No challenges selected')),
      );
    }

    final currentChallengeId = widget.challengeIds[currentChallengeIndex];

    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(currentChallengeId);
        if (challenge == null) {
          return Scaffold(
            body: ErrorMessage(
              message: 'Challenge not found',
              showRetry: false,
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        final userParticipant = provider.getCurrentUserParticipant(currentChallengeId);
        if (userParticipant == null) {
          return Scaffold(
            body: ErrorMessage(
              message: 'You are not an accepted participant in this challenge',
              showRetry: false,
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        return IntegratedDailyLogPage(
          challengeId: currentChallengeId,
          challengeTitle: challenge.title,
          userParticipant: userParticipant,
          isMultiChallenge: widget.challengeIds.length > 1,
          challengeProgress: '${currentChallengeIndex + 1} of ${widget.challengeIds.length}',
          onComplete: _onChallengeLogged,
        );
      },
    );
  }
}