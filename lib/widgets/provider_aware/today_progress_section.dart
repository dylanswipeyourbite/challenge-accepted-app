import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';

class TodayProgressSection extends StatelessWidget {
  final String challengeId;
  final VoidCallback onLogActivity;

  const TodayProgressSection({
    super.key,
    required this.challengeId,
    required this.onLogActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        if (challenge == null) return const SizedBox.shrink();

        final todayStatus = challenge['todayStatus'] as Map<String, dynamic>?;
        final hasLoggedToday = provider.todayLogStatus[challengeId] ?? false;
        
        final loggedCount = todayStatus?['participantsLoggedCount'] as int? ?? 0;
        final totalCount = todayStatus?['totalParticipants'] as int? ?? 0;
        final progress = totalCount > 0 ? loggedCount / totalCount : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$loggedCount/$totalCount logged',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? Colors.green : Colors.orange,
                  ),
                  minHeight: 8,
                ),
              ),
              if (!hasLoggedToday) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLogActivity,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Your Activity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}