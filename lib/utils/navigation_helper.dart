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
    // Store providers before navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPage(challengeId: challengeId),
      ),
    );
    
    // Handle result if activity was logged
    if (result == true) {
      // Don't use context here, use the stored providers
      await Future.wait([
        challengeProvider.refresh(),
        userActivityProvider.refresh(),
      ]);
    }
  }
  
  // Navigate to daily log using only challenge ID
  static Future<void> navigateToDailyLog(
    BuildContext context,
    String challengeId,
  ) async {
    // Store providers before navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDailyLogPage(challengeId: challengeId),
      ),
    );
    
    if (result == true) {
      // Don't use context here, use the stored providers
      await Future.wait([
        challengeProvider.refresh(),
        userActivityProvider.refresh(),
      ]);
    }
  }
  
  // Safe navigation to daily log with completion callback
  static Future<void> navigateToDailyLogWithCallback(
    BuildContext context,
    String challengeId,
  ) async {
    // Store providers before navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderAwareDailyLogPage(
          challengeId: challengeId,
          onComplete: () async {
            // Pop the daily log page
            Navigator.of(context).pop();
            
            // Refresh providers after a short delay to ensure navigation is complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            await Future.wait([
              challengeProvider.refresh(),
              userActivityProvider.refresh(),
            ]);
          },
        ),
      ),
    );
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
        // Don't pop here - let the daily log page handle its own navigation
      },
    );
  }
}