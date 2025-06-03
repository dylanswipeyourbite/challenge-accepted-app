import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';

class LeaderboardSection extends StatelessWidget {
  final String challengeId;

  const LeaderboardSection({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        if (challenge == null) return const SizedBox.shrink();

        final participants = challenge['participants'] as List? ?? [];
        final challengeType = challenge['type'] as String? ?? '';
        
        // Filter and sort participants by total points
        final rankedParticipants = participants
            .where((p) => p['status'] == 'accepted')
            .toList()
          ..sort((a, b) {
            final pointsA = a['totalPoints'] as int? ?? 0;
            final pointsB = b['totalPoints'] as int? ?? 0;
            return pointsB.compareTo(pointsA); // Descending order
          });

        if (rankedParticipants.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.leaderboard, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (challengeType == 'competitive')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COMPETITIVE',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...rankedParticipants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value as Map<String, dynamic>;
                return _LeaderboardTile(
                  rank: index + 1,
                  participant: participant,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> participant;

  const _LeaderboardTile({
    required this.rank,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    final user = participant['user'] as Map<String, dynamic>?;
    final totalPoints = participant['totalPoints'] as int? ?? 0;
    final dailyStreak = participant['dailyStreak'] as int? ?? 0;
    final isCurrentUser = participant['isCurrentUser'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.blue.withOpacity(0.1)
            : rank <= 3
                ? Colors.amber.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? Colors.blue.withOpacity(0.3)
              : rank <= 3
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      rank == 1
                          ? Icons.looks_one
                          : rank == 2
                              ? Icons.looks_two
                              : Icons.looks_3,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            backgroundImage: user?['avatarUrl'] != null
                ? NetworkImage(user!['avatarUrl'] as String)
                : null,
            backgroundColor: Colors.grey.shade300,
            radius: 20,
            child: user?['avatarUrl'] == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?['displayName'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$dailyStreak day streak',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalPoints.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }
}