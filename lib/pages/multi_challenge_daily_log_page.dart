import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/widgets/dialogs/activity_success_dialog.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';

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

  void _onChallengeLogged(String challengeId, int points, int streak, String challengeTitle) {
    setState(() {
      completedChallenges[challengeId] = true;
      totalPointsEarned += points;
      if (streak > highestStreak) {
        highestStreak = streak;
      }
      lastCompletedChallengeTitle = challengeTitle;
      
      if (currentChallengeIndex < widget.challengeIds.length - 1) {
        // Show intermediate success dialog
        _showIntermediateSuccess(points, streak, challengeTitle);
      } else {
        // Show final completion dialog
        _showFinalCompletionDialog();
      }
    });
  }

  void _showIntermediateSuccess(int points, int streak, String challengeTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivitySuccessDialog(
        pointsEarned: points,
        newStreak: streak,
        challengeTitle: challengeTitle,
        isLastChallenge: false,
        onComplete: () {
          setState(() {
            currentChallengeIndex++;
          });
        },
      ),
    );
  }

  void _showFinalCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivitySuccessDialog(
        pointsEarned: totalPointsEarned,
        newStreak: highestStreak,
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

    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getChallenge),
        variables: {'id': currentChallengeId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        if (result.hasException) {
          return Scaffold(
            body: ErrorMessage(
              message: 'Error loading challenge',
              error: result.exception.toString(),
              onRetry: refetch,
            ),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Not authenticated')),
          );
        }

        final challengeData = result.data?['challenge'] as Map<String, dynamic>?;
        if (challengeData == null) {
          return const Scaffold(
            body: Center(child: Text('Challenge not found')),
          );
        }

        final userParticipant = _findUserParticipant(challengeData);
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

        return EnhancedDailyLogPage(
          challengeId: currentChallengeId,
          challengeTitle: challengeData['title'] as String,
          userParticipant: userParticipant,
          isMultiChallenge: widget.challengeIds.length > 1,
          challengeProgress: '${currentChallengeIndex + 1} of ${widget.challengeIds.length}',
          onComplete: (points, streak) => _onChallengeLogged(
            currentChallengeId,
            points,
            streak,
            challengeData['title'] as String,
          ),
        );
      },
    );
  }

  Map<String, dynamic>? _findUserParticipant(Map<String, dynamic> challenge) {
    final participants = challenge['participants'] as List<dynamic>;
    
    try {
      return participants.firstWhere(
        (p) => p['isCurrentUser'] == true && p['status'] == 'accepted',
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

// Enhanced version of IntegratedDailyLogPage that returns points and streak
class EnhancedDailyLogPage extends StatelessWidget {
  final String challengeId;
  final String challengeTitle;
  final Map<String, dynamic> userParticipant;
  final bool isMultiChallenge;
  final String? challengeProgress;
  final Function(int points, int streak) onComplete;

  const EnhancedDailyLogPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.userParticipant,
    this.isMultiChallenge = false,
    this.challengeProgress,
    required this.onComplete,
  });

  int get allowedRestDays => userParticipant['restDays'] as int? ?? 1;
  int get usedRestDays => userParticipant['weeklyRestDaysUsed'] as int? ?? 0;
  int get currentStreak => userParticipant['dailyStreak'] as int? ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Today - $challengeTitle'),
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
            if (currentStreak > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '$currentStreak Day Streak!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (usedRestDays < allowedRestDays)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bed, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rest days available: ${allowedRestDays - usedRestDays}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            EnhancedDailyLogForm(
              challengeId: challengeId,
              challengeTitle: challengeTitle,
              canTakeRestDay: usedRestDays < allowedRestDays,
              onComplete: onComplete,
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced form that passes points and streak to parent
class EnhancedDailyLogForm extends StatelessWidget {
  final String challengeId;
  final String challengeTitle;
  final bool canTakeRestDay;
  final Function(int points, int streak) onComplete;

  const EnhancedDailyLogForm({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.canTakeRestDay,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // This would be your existing DailyLogForm but modified to call onComplete with points and streak
    // For now, using a simplified version
    return ElevatedButton(
      onPressed: () {
        // Simulate completion with mock data
        // In reality, this would come from the mutation result
        onComplete(10, 5); // 10 points, 5 day streak
      },
      child: const Text('Log Activity'),
    );
  }
}