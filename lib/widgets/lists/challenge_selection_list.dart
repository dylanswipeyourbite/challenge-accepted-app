// lib/widgets/lists/challenge_selection_list.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/cards/selectable_challenge_card.dart';

class ChallengeSelectionList extends StatelessWidget {
  final List<dynamic> challenges;
  final Set<String> selectedChallengeIds;
  final Function(String, bool) onChallengeToggled;

  const ChallengeSelectionList({
    super.key,
    required this.challenges,
    required this.selectedChallengeIds,
    required this.onChallengeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index] as Map<String, dynamic>;
        final userParticipant = _findUserParticipant(challenge);
        
        if (userParticipant == null) {
          return const SizedBox.shrink();
        }

        return SelectableChallengeCard(
          challenge: challenge,
          userParticipant: userParticipant,
          isSelected: selectedChallengeIds.contains(challenge['id'] as String),
          onToggle: (selected) => onChallengeToggled(
            challenge['id'] as String,
            selected,
          ),
        );
      },
    );
  }

  Map<String, dynamic>? _findUserParticipant(Map<String, dynamic> challenge) {
    final participants = challenge['participants'] as List<dynamic>;
    
    try {
      return participants.firstWhere(
        (p) => p['isCurrentUser'] == true && p['status'] == 'accepted',
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}