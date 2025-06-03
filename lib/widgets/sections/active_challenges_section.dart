import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/subscriptions/challenge_subscriptions.dart';
import 'package:challengeaccepted/widgets/cards/active_challenge_card.dart';
import 'package:challengeaccepted/pages/challenge_detail_pagev2.dart';
import 'package:challengeaccepted/utils/graphql_helpers.dart';

class ActiveChallengesSection extends StatelessWidget {
  const ActiveChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Active Challenges",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Query(
          options: QueryOptions(
            document: gql(ChallengesQueries.getActiveChallenges),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Text('Error: ${result.exception.toString()}');
            }
            
            final challenges = result.data?['challenges'] as List<dynamic>? ?? [];
            final processedChallenges = _processAndSortChallenges(challenges);

            if (processedChallenges.isEmpty) {
              return const _EmptyChallengesMessage();
            }

            return _ChallengesList(
              challenges: challenges,
              processedChallenges: processedChallenges,
              onRefresh: refetch,
              onNavigateToChallenge: (challenge) => _navigateToChallenge(context, challenge, refetch),
            );
          },
        ),
      ],
    );
  }

  Future<void> _navigateToChallenge(
    BuildContext context, 
    Map<String, dynamic> challenge,
    VoidCallback? refetch,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPageV2(challenge: challenge),
      ),
    );
    
    // If we returned with a result indicating activity was logged
    if (result == true) {
      // Force refresh
      refetch?.call();
      
      // Also refresh using GraphQL helpers
      final client = GraphQLProvider.of(context).value;
      await GraphQLHelpers.refetchAfterPost(client, challenge['id'] as String);
    }
  }

  List<Map<String, dynamic>> _processAndSortChallenges(List<dynamic> challenges) {
    final List<Map<String, dynamic>> processedList = [];
    
    for (final challenge in challenges) {
      if (challenge['status'] == 'expired') continue;
      
      final participants = challenge['participants'] as List<dynamic>?;
      if (participants == null) continue;
      
      try {
        // Find the current user's participant record
        final currentUserParticipant = participants.firstWhere(
          (p) => p['isCurrentUser'] == true,
        );
        
        // Check if the current user has accepted
        if (currentUserParticipant['status'] != 'accepted') continue;
        
        // Check if user has logged today using todayStatus
        bool hasLoggedToday = false;
        final todayStatus = challenge['todayStatus'] as Map<String, dynamic>?;
        if (todayStatus != null) {
          final participantsStatus = todayStatus['participantsStatus'] as List?;
          if (participantsStatus != null) {
            try {
              final currentUserStatus = participantsStatus.firstWhere(
                (status) => status['participant']['isCurrentUser'] == true,
              );
              hasLoggedToday = currentUserStatus['hasLoggedToday'] as bool? ?? false;
            } catch (_) {
              // Current user not found in today's status
            }
          }
        }
        
        processedList.add({
          'challenge': challenge,
          'needsLogging': !hasLoggedToday,
        });
      } catch (_) {
        continue;
      }
    }
    
    // Sort: challenges needing logging first
    processedList.sort((a, b) {
      if (a['needsLogging'] && !b['needsLogging']) return -1;
      if (!a['needsLogging'] && b['needsLogging']) return 1;
      return 0;
    });
    
    return processedList;
  }
}

class _EmptyChallengesMessage extends StatelessWidget {
  const _EmptyChallengesMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "No active challenges yet. Accept some invites to get started! 💪",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _ChallengesList extends StatelessWidget {
  final List<dynamic> challenges;
  final List<Map<String, dynamic>> processedChallenges;
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic>) onNavigateToChallenge;

  const _ChallengesList({
    required this.challenges,
    required this.processedChallenges,
    this.onRefresh,
    required this.onNavigateToChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Subscription(
      options: SubscriptionOptions(
        document: gql(ChallengeSubscriptions.challengeUpdated),
      ),
      builder: (subResult) {
        // Refresh on subscription update
        if (subResult.data != null && onRefresh != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onRefresh!();
          });
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: processedChallenges.length,
            itemBuilder: (context, index) {
              final item = processedChallenges[index];
              final challenge = item['challenge'] as Map<String, dynamic>;
              
              return GestureDetector(
                onTap: () => onNavigateToChallenge(challenge),
                child: ActiveChallengeCard(
                  challenge: challenge,
                  needsLogging: item['needsLogging'] as bool,
                ),
              );
            },
          ),
        );
      },
    );
  }
}