// lib/widgets/sections/active_challenges_section.dart

import 'package:challengeaccepted/utils/graphql_helpers.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/subscriptions/challenge_subscriptions.dart';
import 'package:challengeaccepted/widgets/cards/active_challenge_card.dart';

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
            fetchPolicy: GraphQLHelpers.getFetchPolicyFor(QueryType.activeStats),
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Text('Error: ${result.exception.toString()}');
            }
            
            final challenges = result.data?['challenges'] as List<dynamic>? ?? [];
            final activeChallenges = _filterActiveChallenges(challenges);

            if (activeChallenges.isEmpty) {
              return const _EmptyChallengesMessage();
            }

            return _ChallengesList(
              challenges: challenges,
              activeChallenges: activeChallenges,
            );
          },
        ),
      ],
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
  final List<dynamic> activeChallenges;

  const _ChallengesList({
    required this.challenges,
    required this.activeChallenges,
  });

  @override
  Widget build(BuildContext context) {
    return Subscription(
      options: SubscriptionOptions(
        document: gql(ChallengeSubscriptions.challengeUpdated),
      ),
      builder: (subResult) {
        final displayChallenges = _updateWithSubscriptionData(
          subResult.data,
          challenges,
          activeChallenges,
        );

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayChallenges.length,
            itemBuilder: (context, index) {
              final challenge = displayChallenges[index];
              return ActiveChallengeCard(challenge: challenge);
            },
          ),
        );
      },
    );
  }

  List<dynamic> _updateWithSubscriptionData(
    Map<String, dynamic>? subscriptionData,
    List<dynamic> allChallenges,
    List<dynamic> currentActiveChallenges,
  ) {
    final updated = subscriptionData?['challengeUpdated'];
    if (updated == null) return currentActiveChallenges;
    
    // Update the challenge list with new data
    final index = allChallenges.indexWhere((c) => c['id'] == updated['id']);
    if (index != -1) {
      allChallenges[index] = updated;
    } else {
      allChallenges.add(updated);
    }
    
    // Re-filter for active challenges
    return allChallenges.where((challenge) {
      if (challenge['status'] == 'expired') return false;
      
      final participants = challenge['participants'] as List<dynamic>?;
      if (participants == null) return false;
      
      try {
        participants.firstWhere(
          (p) => p['user'] != null && p['status'] == 'accepted',
        );
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }
}