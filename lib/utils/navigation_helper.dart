// lib/utils/navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/pages/challenge_detail_page.dart';
import 'package:challengeaccepted/pages/daily_log_page.dart';

class NavigationHelper {
  // Navigate to challenge detail using only challenge ID
  static Future<void> navigateToChallengeDetail(
    BuildContext context,
    String challengeId,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPage(challengeId: challengeId),
      ),
    );
    
    // Handle result if activity was logged
    if (result == true && context.mounted) {
      await context.read<ChallengeProvider>().refresh();
      await context.read<UserActivityProvider>().refresh();
    }
  }
  
  // Navigate to daily log using only challenge ID
  static Future<void> navigateToDailyLog(
    BuildContext context,
    String challengeId,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDailyLogPage(challengeId: challengeId),
      ),
    );
    
    if (result == true && context.mounted) {
      // Refresh data after logging
      await context.read<ChallengeProvider>().refresh();
      await context.read<UserActivityProvider>().refresh();
    }
  }
}

// Provider-aware Daily Log Page
class ProviderDailyLogPage extends StatelessWidget {
  final String challengeId;
  
  const ProviderDailyLogPage({
    super.key,
    required this.challengeId,
  });
  
  @override
  Widget build(BuildContext context) {
    // Use the new provider-aware version directly
    return ProviderAwareDailyLogPage(
      challengeId: challengeId,
      onComplete: () {
        Navigator.of(context).pop(true);
      },
    );
  }
}