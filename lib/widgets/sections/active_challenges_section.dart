import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/widgets/cards/active_challenge_card.dart';
import 'package:challengeaccepted/utils/navigation_helper.dart';

class ActiveChallengesSection extends StatelessWidget {
  const ActiveChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Active Challenges",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer<ChallengeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.activeChallenges.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Text('Error: ${provider.error}');
            }
            
            final processedChallenges = _processAndSortChallenges(
              provider.activeChallenges,
              provider.todayLogStatus,
            );

            if (processedChallenges.isEmpty) {
              return const _EmptyChallengesMessage();
            }

            return _ChallengesList(
              processedChallenges: processedChallenges,
            );
          },
        ),
      ],
    );
  }



  List<Map<String, dynamic>> _processAndSortChallenges(
    List<Map<String, dynamic>> challenges,
    Map<String, bool> todayLogStatus,
  ) {
    final List<Map<String, dynamic>> processedList = [];
    
    for (final challenge in challenges) {
      final challengeId = challenge['id'] as String;
      final hasLoggedToday = todayLogStatus[challengeId] ?? false;
      
      processedList.add({
        'challenge': challenge,
        'needsLogging': !hasLoggedToday,
      });
    }
    
    // Sort: challenges needing logging first
    processedList.sort((a, b) {
      if (a['needsLogging'] && !b['needsLogging']) return -1;
      if (!a['needsLogging'] && b['needsLogging']) return 1;
      return 0;
    });
    
    return processedList;
  }
}

class _EmptyChallengesMessage extends StatelessWidget {
  const _EmptyChallengesMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "No active challenges yet. Accept some invites to get started! 💪",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _ChallengesList extends StatelessWidget {
  final List<Map<String, dynamic>> processedChallenges;

  const _ChallengesList({
    required this.processedChallenges,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: processedChallenges.length,
        itemBuilder: (context, index) {
          final item = processedChallenges[index];
          final challenge = item['challenge'] as Map<String, dynamic>;
          
          return GestureDetector(
            onTap: () => NavigationHelper.navigateToChallengeDetail(
              context,
              challenge['id'] as String,
            ),
            child: ActiveChallengeCard(
              challenge: challenge,
              needsLogging: item['needsLogging'] as bool,
            ),
          );
        },
      ),
    );
  }
}