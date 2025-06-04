// lib/widgets/cards/selectable_challenge_card.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/models/participant.dart';

class SelectableChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final Participant userParticipant;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const SelectableChallengeCard({
    super.key,
    required this.challenge,
    required this.userParticipant,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final streak = userParticipant.dailyStreak;
    final totalPoints = userParticipant.totalPoints;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.green.shade50 : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onToggle(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCheckbox(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChallengeInfo(streak, totalPoints),
              ),
              _buildTypeIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey,
          width: 2,
        ),
        color: isSelected ? Colors.green : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildChallengeInfo(int streak, int totalPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStatChip(
              icon: Icons.local_fire_department,
              value: '$streak day streak',
              color: Colors.orange.shade600,
            ),
            const SizedBox(width: 16),
            _buildStatChip(
              icon: Icons.star,
              value: '$totalPoints points',
              color: Colors.amber.shade600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeIcon() {
    return Icon(
      challenge.type.icon,
      color: Colors.grey,
    );
  }
}