import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/widgets/cards/stat_card.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserActivityProvider>(
      builder: (context, provider, child) {
        print('QuickStatsSection: isLoading=${provider.isLoadingStats}, error=${provider.error}, streak=${provider.currentStreak}');
        
        if (provider.isLoadingStats && provider.currentStreak == 0) {
          return const _LoadingStats();
        }

        if (provider.error != null) {
          return _ErrorStats(
            error: provider.error!,
            onRetry: () => provider.fetchUserStats(),
          );
        }

        return _StatsContent(
          currentStreak: provider.currentStreak,
          totalPoints: provider.totalPoints,
          completedChallenges: provider.completedChallenges,
        );
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

class _ErrorStats extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorStats({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('Error loading stats'),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final int currentStreak;
  final int totalPoints;
  final int completedChallenges;

  const _StatsContent({
    required this.currentStreak,
    required this.totalPoints,
    required this.completedChallenges,
  });

  @override
  Widget build(BuildContext context) {
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