// lib/widgets/cards/participant_card.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/participant.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';

class ParticipantCard extends StatelessWidget {
  final Participant participant;
  final int rank;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final user = participant.user;
    final streak = participant.dailyStreak;
    final role = participant.role;
    final status = participant.status;
    final totalPoints = participant.totalPoints;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildLeading(user.avatarUrl),
        title: _buildTitle(user.displayName, role),
        subtitle: _buildSubtitle(streak, totalPoints, status),
        trailing: _buildTrailing(streak),
      ),
    );
  }

  Widget _buildLeading(String? avatarUrl) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        if (rank <= 3)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getRankColor(),
                shape: BoxShape.circle,
              ),
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(String displayName, ParticipantRole role) {
    return Row(
      children: [
        Text(displayName),
        if (role == ParticipantRole.creator) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Creator',
              style: TextStyle(
                color: Colors.purple.shade700,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitle(int streak, int totalPoints, ParticipantStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🔥 $streak day streak • ⭐ $totalPoints points"),
        if (status == ParticipantStatus.pending)
          Text(
            'Pending invitation',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing(int streak) {
    if (streak == 0) return const SizedBox.shrink();

    IconData icon;
    Color color;

    if (streak >= 30) {
      icon = Icons.whatshot;
      color = Colors.red;
    } else if (streak >= 14) {
      icon = Icons.local_fire_department;
      color = Colors.orange;
    } else if (streak >= 7) {
      icon = Icons.wb_sunny;
      color = Colors.amber;
    } else {
      icon = Icons.star_outline;
      color = Colors.grey;
    }

    return Icon(icon, color: color);
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}