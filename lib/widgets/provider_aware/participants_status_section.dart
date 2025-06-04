// lib/widgets/provider_aware/participants_status_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/models/participant_daily_status.dart';

class ParticipantsStatusSection extends StatelessWidget {
  final String challengeId;

  const ParticipantsStatusSection({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        if (challenge == null) return const SizedBox.shrink();

        final participantsStatus = challenge.todayStatus?.participantsStatus ?? [];
        
        if (participantsStatus.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Members Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...participantsStatus.map((status) {
                return _ParticipantStatusTile(status: status);
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _ParticipantStatusTile extends StatelessWidget {
  final ParticipantDailyStatus status;

  const _ParticipantStatusTile({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final participant = status.participant;
    final user = participant.user;
    final hasLoggedToday = status.hasLoggedToday;
    final isCurrentUser = participant.isCurrentUser;
  

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasLoggedToday 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLoggedToday
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.avatarUrl != null 
                ? NetworkImage(user.avatarUrl!)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: user.avatarUrl == null 
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.displayName,
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
                Text(
                  hasLoggedToday 
                      ? 'Logged today ${status.timeSinceLog}'
                      : 'Not logged yet',
                  style: TextStyle(
                    color: hasLoggedToday 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasLoggedToday ? Icons.check_circle : Icons.circle_outlined,
            color: hasLoggedToday ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }
}