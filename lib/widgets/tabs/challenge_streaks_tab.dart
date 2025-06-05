// lib/widgets/tabs/challenge_streaks_tab.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/models/participant.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:challengeaccepted/widgets/lists/participant_list.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';

class ChallengeStreaksTab extends StatelessWidget {
  final String challengeId;

  const ChallengeStreaksTab({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getChallenge),
        variables: {'id': challengeId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading && result.data == null) {
          return const LoadingIndicator();
        }

        if (result.hasException) {
          return ErrorMessage(
            message: 'Failed to load participants',
            error: result.exception.toString(),
            onRetry: refetch,
          );
        }

        final challengeData = result.data?['challenge'] as Map<String, dynamic>?;
        if (challengeData == null) {
          return const Center(child: Text('Challenge not found'));
        }

        // Parse the challenge data to get typed Challenge object
        final challenge = Challenge.fromJson(challengeData);
        final participants = challenge.participants;

        return Column(
          children: [
            _buildChallengeStats(participants),
            const Divider(),
            Expanded(
              child: ParticipantList(
                participants: participants,
                onRefresh: refetch,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChallengeStats(List<Participant> participants) {
    // Now we can use proper typed access
    final activeCount = participants.where((p) => p.status == ParticipantStatus.accepted).length;
    final totalStreak = participants.fold<int>(
      0,
      (sum, p) => sum + p.dailyStreak,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(
            icon: Icons.people,
            label: 'Active',
            value: activeCount.toString(),
            color: Colors.blue,
          ),
          _StatChip(
            icon: Icons.local_fire_department,
            label: 'Total Streak',
            value: totalStreak.toString(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}