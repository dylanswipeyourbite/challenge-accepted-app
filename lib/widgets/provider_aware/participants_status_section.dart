import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';

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

        final todayStatus = challenge['todayStatus'] as Map<String, dynamic>?;
        final participantsStatus = todayStatus?['participantsStatus'] as List? ?? [];
        
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
                final participant = status['participant'] as Map<String, dynamic>;
                final user = participant['user'] as Map<String, dynamic>?;
                final hasLogged = status['hasLoggedToday'] as bool? ?? false;
                final isCurrentUser = participant['isCurrentUser'] as bool? ?? false;
                
                return _ParticipantStatusTile(
                  displayName: user?['displayName'] as String? ?? 'Unknown',
                  avatarUrl: user?['avatarUrl'] as String?,
                  hasLoggedToday: hasLogged,
                  isCurrentUser: isCurrentUser,
                  lastLogTime: _parseDateTime(status['lastLogTime']),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}

class _ParticipantStatusTile extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final bool hasLoggedToday;
  final bool isCurrentUser;
  final DateTime? lastLogTime;

  const _ParticipantStatusTile({
    required this.displayName,
    this.avatarUrl,
    required this.hasLoggedToday,
    required this.isCurrentUser,
    this.lastLogTime,
  });

  @override
  Widget build(BuildContext context) {
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
            backgroundImage: avatarUrl != null 
                ? NetworkImage(avatarUrl!)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: avatarUrl == null 
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
                      displayName,
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
                      ? 'Logged today ${_formatTime(lastLogTime)}'
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

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '';
  }
}