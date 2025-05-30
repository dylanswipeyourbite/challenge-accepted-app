// lib/widgets/sections/quick_actions_section.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/pages/daily_activity_selector_page.dart';
import 'package:challengeaccepted/pages/create_challenge_page.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getActiveChallenges),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        final stats = _calculateChallengeStats(result.data);
        
        return Row(
          children: [
            Expanded(
              child: _LogActivityButton(
                challengesNeedingLog: stats.needingLog,
                totalActiveChallenges: stats.total,
                allLogged: stats.allLogged,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: _NewChallengeButton()),
          ],
        );
      },
    );
  }

  _ChallengeStats _calculateChallengeStats(Map<String, dynamic>? data) {
    if (data == null) return const _ChallengeStats(0, 0, false);
    
    final challenges = data['challenges'] as List<dynamic>? ?? [];
    int challengesNeedingLog = 0;
    int totalActiveChallenges = 0;
    
    for (final challenge in challenges) {
      if (challenge['status'] == 'expired') continue;
      
      final participants = challenge['participants'] as List<dynamic>?;
      if (participants == null) continue;
      
      final userParticipant = _findAcceptedParticipant(participants);
      if (userParticipant == null) continue;
      
      totalActiveChallenges++;
      
      if (!_hasLoggedToday(userParticipant['lastLogDate'])) {
        challengesNeedingLog++;
      }
    }
    
    return _ChallengeStats(
      challengesNeedingLog,
      totalActiveChallenges,
      totalActiveChallenges > 0 && challengesNeedingLog == 0,
    );
  }

  Map<String, dynamic>? _findAcceptedParticipant(List<dynamic> participants) {
    try {
      return participants.firstWhere(
        (p) => p['isCurrentUser'] == true && p['status'] == 'accepted',
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool _hasLoggedToday(dynamic lastLogDateStr) {
    if (lastLogDateStr == null) return false;
    
    final lastLog = DateTime.tryParse(lastLogDateStr as String);
    if (lastLog == null) return false;
    
    final today = DateTime.now();
    return lastLog.year == today.year &&
           lastLog.month == today.month &&
           lastLog.day == today.day;
  }
}

class _ChallengeStats {
  final int needingLog;
  final int total;
  final bool allLogged;

  const _ChallengeStats(this.needingLog, this.total, this.allLogged);
}

class _LogActivityButton extends StatelessWidget {
  final int challengesNeedingLog;
  final int totalActiveChallenges;
  final bool allLogged;

  const _LogActivityButton({
    required this.challengesNeedingLog,
    required this.totalActiveChallenges,
    required this.allLogged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        onPressed: () => _handlePress(context),
        icon: Icon(
          allLogged ? Icons.check_circle : Icons.fitness_center,
          color: allLogged ? Colors.green.shade700 : Colors.white,
        ),
        label: Text(
          _getButtonText(),
          style: TextStyle(
            color: allLogged ? Colors.green.shade700 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: _getButtonStyle(),
      ),
    );
  }

  void _handlePress(BuildContext context) {
    if (totalActiveChallenges == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join a challenge first to start logging activities!'),
        ),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DailyActivitySelectorPage()),
    );
  }

  String _getButtonText() {
    if (allLogged) return 'All Done Today! 🎉';
    if (challengesNeedingLog > 0) return 'Log Activity ($challengesNeedingLog)';
    return 'Log Activity';
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: allLogged ? Colors.green.shade50 : Colors.green,
      foregroundColor: allLogged ? Colors.green.shade700 : Colors.white,
      side: allLogged 
          ? BorderSide(color: Colors.green.shade300, width: 2)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: allLogged ? 0 : 2,
    );
  }
}

class _NewChallengeButton extends StatelessWidget {
  const _NewChallengeButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateChallengePage()),
        );
      },
      icon: const Icon(Icons.emoji_events),
      label: const Text('New Challenge'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.blue, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}