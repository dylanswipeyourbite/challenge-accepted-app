import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/widgets/lists/challenge_selection_list.dart';
import 'package:challengeaccepted/widgets/common/empty_state.dart';
import 'package:challengeaccepted/pages/multi_challenge_daily_log_page.dart';

class DailyActivitySelectorPage extends StatefulWidget {
  const DailyActivitySelectorPage({super.key});

  @override
  State<DailyActivitySelectorPage> createState() => _DailyActivitySelectorPageState();
}

class _DailyActivitySelectorPageState extends State<DailyActivitySelectorPage> {
  final Set<String> selectedChallengeIds = {};

  void _onChallengeToggled(String challengeId, bool selected) {
    setState(() {
      if (selected) {
        selectedChallengeIds.add(challengeId);
      } else {
        selectedChallengeIds.remove(challengeId);
      }
    });
  }

  void _navigateToLogging() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiChallengeDailyLogPage(
          challengeIds: selectedChallengeIds.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Challenges'),
        actions: [
          TextButton(
            onPressed: selectedChallengeIds.isEmpty ? null : _navigateToLogging,
            child: Text(
              'Next (${selectedChallengeIds.length})',
              style: TextStyle(
                color: selectedChallengeIds.isEmpty ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.challengesNeedingLog.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final challengesNeedingLog = provider.challengesNeedingLog;

          if (challengesNeedingLog.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle,
              title: 'All done for today!',
              message: 'You\'ve logged all your challenges. Great job! 🎉',
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return Column(
            children: [
              _buildInfoHeader(challengesNeedingLog.length),
              Expanded(
                child: ChallengeSelectionList(
                  challenges: challengesNeedingLog,
                  selectedChallengeIds: selectedChallengeIds,
                  onChallengeToggled: _onChallengeToggled,
                ),
              ),
              if (selectedChallengeIds.isNotEmpty)
                _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count challenge${count != 1 ? 's' : ''} need${count == 1 ? 's' : ''} logging today',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _navigateToLogging,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log ${selectedChallengeIds.length} Challenge${selectedChallengeIds.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}