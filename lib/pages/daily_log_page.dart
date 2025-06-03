// Update the IntegratedDailyLogPage in lib/pages/daily_log_page.dart
// This shows the key change to return a result when activity is logged

import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/forms/daily_log_form.dart';
import 'package:challengeaccepted/widgets/cards/streak_display_card.dart';
import 'package:challengeaccepted/widgets/cards/rest_day_info_card.dart';

class IntegratedDailyLogPage extends StatelessWidget {
  final String challengeId;
  final String challengeTitle;
  final Map<String, dynamic> userParticipant;
  final bool isMultiChallenge;
  final String? challengeProgress;
  final VoidCallback? onComplete;

  const IntegratedDailyLogPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.userParticipant,
    this.isMultiChallenge = false,
    this.challengeProgress,
    this.onComplete,
  });

  int get allowedRestDays => userParticipant['restDays'] as int? ?? 1;
  int get usedRestDays => userParticipant['weeklyRestDaysUsed'] as int? ?? 0;
  int get currentStreak => userParticipant['dailyStreak'] as int? ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Today - $challengeTitle'),
            if (isMultiChallenge && challengeProgress != null)
              Text(
                'Challenge $challengeProgress',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreakDisplayCard(currentStreak: currentStreak),
            const SizedBox(height: 24),
            RestDayInfoCard(
              usedRestDays: usedRestDays,
              allowedRestDays: allowedRestDays,
            ),
            const SizedBox(height: 24),
            DailyLogForm(
              challengeId: challengeId,
              canTakeRestDay: usedRestDays < allowedRestDays,
              challengeTitle: challengeTitle, // Add this line
              onComplete: () {
                // Return true to indicate successful logging
                Navigator.of(context).pop(true);
                onComplete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}