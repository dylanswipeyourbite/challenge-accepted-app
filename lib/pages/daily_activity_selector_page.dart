// lib/pages/daily_activity_selector_page.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/widgets/lists/challenge_selection_list.dart';
import 'package:challengeaccepted/widgets/common/empty_state.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/pages/multi_challenge_daily_log_page.dart';

class DailyActivitySelectorPage extends StatefulWidget {
  const DailyActivitySelectorPage({super.key});

  @override
  State<DailyActivitySelectorPage> createState() => _DailyActivitySelectorPageState();
}

class _DailyActivitySelectorPageState extends State<DailyActivitySelectorPage> {
  final Set<String> selectedChallengeIds = {};

  void _onChallengeToggled(String challengeId, bool selected) {
    setState(() {
      if (selected) {
        selectedChallengeIds.add(challengeId);
      } else {
        selectedChallengeIds.remove(challengeId);
      }
    });
  }

  void _navigateToLogging() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiChallengeDailyLogPage(
          challengeIds: selectedChallengeIds.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Challenges'),
        actions: [
          TextButton(
            onPressed: selectedChallengeIds.isEmpty ? null : _navigateToLogging,
            child: Text(
              'Next (${selectedChallengeIds.length})',
              style: TextStyle(
                color: selectedChallengeIds.isEmpty ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(ChallengesQueries.getActiveChallenges),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.isLoading && result.data == null) {
            return const LoadingIndicator();
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return const EmptyState(
              icon: Icons.account_circle,
              title: 'Not authenticated',
              message: 'Please log in to continue',
            );
          }

          final challenges = result.data?['challenges'] as List<dynamic>? ?? [];
          final activeChallenges = _filterActiveChallenges(challenges);

          if (activeChallenges.isEmpty) {
            return EmptyState(
              icon: Icons.info_outline,
              title: 'No active challenges',
              message: 'Join a challenge first to log activities',
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return Column(
            children: [
              _buildInfoHeader(),
              Expanded(
                child: ChallengeSelectionList(
                  challenges: activeChallenges,
                  selectedChallengeIds: selectedChallengeIds,
                  onChallengeToggled: _onChallengeToggled,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select the challenges you want to log activity for',
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterActiveChallenges(List<dynamic> challenges) {
    return challenges.where((challenge) {
      if (challenge['status'] == 'expired') return false;
      
      final participants = challenge['participants'] as List<dynamic>?;
      if (participants == null) return false;
      
      try {
        // Find the current user's participant record
        final currentUserParticipant = participants.firstWhere(
          (p) => p['isCurrentUser'] == true,
        );
        
        // Check if the current user has accepted
        return currentUserParticipant['status'] == 'accepted';
      } catch (_) {
        return false;
      }
    }).toList();
  }
}