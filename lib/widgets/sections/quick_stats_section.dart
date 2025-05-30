// lib/widgets/sections/quick_stats_section.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/user_queries.dart';
import 'package:challengeaccepted/widgets/cards/stat_card.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(UserQueries.getUserStats),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const _LoadingStats();
        }

        final stats = result.data?['userStats'] as Map<String, dynamic>?;
        if (stats == null) {
          return const _EmptyStats();
        }

        return _StatsContent(stats: stats);
      },
    );
  }
}

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatCard(label: "Streak", value: "...", isLoading: true),
        StatCard(label: "Points", value: "...", isLoading: true),
        StatCard(label: "Next Goal", value: "...", isLoading: true),
      ],
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatCard(label: "Streak", value: "0🔥"),
        StatCard(label: "Points", value: "0"),
        StatCard(label: "Challenges", value: "0"),
      ],
    );
  }
}

class _StatsContent extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final currentStreak = stats['currentStreak'] as int? ?? 0;
    final totalPoints = stats['totalPoints'] as int? ?? 0;
    final completedChallenges = stats['completedChallenges'] as int? ?? 0;

    final (thirdStatValue, thirdStatLabel) = _calculateMilestone(totalPoints);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatCard(
          label: "Streak", 
          value: "$currentStreak${currentStreak > 0 ? '🔥' : ''}",
          subtitle: currentStreak > 7 ? "On fire!" : null,
        ),
        StatCard(
          label: "Points", 
          value: totalPoints.toString(),
          subtitle: completedChallenges > 0 ? "$completedChallenges won" : null,
        ),
        StatCard(
          label: thirdStatLabel, 
          value: thirdStatValue,
          isSpecial: true,
        ),
      ],
    );
  }

  (String, String) _calculateMilestone(int totalPoints) {
    if (totalPoints < 100) {
      return ("${100 - totalPoints} to 💯", "Next Milestone");
    } else if (totalPoints < 500) {
      return ("${500 - totalPoints} to 🏆", "Gold Trophy");
    } else if (totalPoints < 1000) {
      return ("${1000 - totalPoints} to 👑", "Champion");
    } else {
      return ("🌟 ${(totalPoints / 1000).toStringAsFixed(1)}K", "Legend Status");
    }
  }
}