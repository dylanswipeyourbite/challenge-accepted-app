// lib/widgets/provider_aware/today_progress_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/pages/daily_log_page.dart';

class TodayProgressSection extends StatelessWidget {
  final String challengeId;
  final VoidCallback? onLogActivity;

  const TodayProgressSection({
    super.key,
    required this.challengeId,
    this.onLogActivity,
  });

  Future<void> _navigateToDailyLog(BuildContext context) async {
    // Store providers before navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderAwareDailyLogPage(
          challengeId: challengeId,
          onComplete: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
    
    if (result == true) {
      // Use stored providers, not context
      await Future.wait([
        challengeProvider.refresh(),
        userActivityProvider.refresh(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        if (challenge == null) return const SizedBox.shrink();

        final todayStatus = challenge.todayStatus;
        final hasLoggedToday = provider.todayLogStatus[challengeId] ?? false;
        
        final loggedCount = todayStatus?.participantsLoggedCount ?? 0;
        final totalCount = todayStatus?.totalParticipants ?? 0;
        final progress = todayStatus?.progressPercentage ?? 0.0;

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
                    onPressed: () => onLogActivity != null 
                        ? onLogActivity!() 
                        : _navigateToDailyLog(context),
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