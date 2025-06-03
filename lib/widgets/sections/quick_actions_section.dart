import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/pages/daily_activity_selector_page.dart';
import 'package:challengeaccepted/pages/create_challenge_page.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _LogActivityButton(
                challengesNeedingLog: provider.challengesNeedingLogCount,
                totalActiveChallenges: provider.activeChallenges.length,
                allLogged: provider.allChallengesLoggedToday,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: _NewChallengeButton()),
          ],
        );
      },
    );
  }
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