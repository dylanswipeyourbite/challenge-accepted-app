// lib/widgets/lists/participant_list.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/cards/participant_card.dart';

class ParticipantList extends StatelessWidget {
  final List<dynamic> participants;
  final VoidCallback? onRefresh;

  const ParticipantList({
    super.key,
    required this.participants,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Center(
        child: Text('No participants yet'),
      );
    }

    final sortedParticipants = List<dynamic>.from(participants)
      ..sort((a, b) {
        final streakA = a['dailyStreak'] as int? ?? 0;
        final streakB = b['dailyStreak'] as int? ?? 0;
        return streakB.compareTo(streakA); // Sort by streak descending
      });

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedParticipants.length,
        itemBuilder: (context, index) {
          final participant = sortedParticipants[index] as Map<String, dynamic>;
          return ParticipantCard(
            participant: participant,
            rank: index + 1,
          );
        },
      ),
    );
  }
}