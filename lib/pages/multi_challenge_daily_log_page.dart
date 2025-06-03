// lib/pages/multi_challenge_daily_log_page.dart

import 'package:challengeaccepted/pages/daily_log_page.dart';
import 'package:challengeaccepted/providers/refresh_provider.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/widgets/dialogs/completion_dialog.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';
import 'package:provider/provider.dart';

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

  void _onChallengeLogged(String challengeId) {
    setState(() {
      completedChallenges[challengeId] = true;
      
      if (currentChallengeIndex < widget.challengeIds.length - 1) {
        currentChallengeIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    // Notify homepage to refresh
    context.read<RefreshProvider>().refreshHomePage();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionDialog(
        title: 'All Done! 🎉',
        message: 'You\'ve logged activity for ${widget.challengeIds.length} challenge${widget.challengeIds.length > 1 ? 's' : ''}!',
        onComplete: () {
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

        return IntegratedDailyLogPage(
          challengeId: currentChallengeId,
          challengeTitle: challengeData['title'] as String,
          userParticipant: userParticipant,
          isMultiChallenge: widget.challengeIds.length > 1,
          challengeProgress: '${currentChallengeIndex + 1} of ${widget.challengeIds.length}',
          onComplete: () => _onChallengeLogged(currentChallengeId),
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