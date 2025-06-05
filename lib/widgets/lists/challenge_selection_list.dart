// lib/widgets/lists/challenge_selection_list.dart
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/widgets/cards/selectable_challenge_card.dart';

class ChallengeSelectionList extends StatelessWidget {
  final List<Challenge> challenges;
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
        final challenge = challenges[index];
        final userParticipant = challenge.currentUserParticipant;
        
        if (userParticipant == null || !userParticipant.isAccepted) {
          return const SizedBox.shrink();
        }

        return SelectableChallengeCard(
          challenge: challenge,
          userParticipant: userParticipant,
          isSelected: selectedChallengeIds.contains(challenge.id),
          onToggle: (selected) => onChallengeToggled(
            challenge.id,
            selected,
          ),
        );
      },
    );
  }
}