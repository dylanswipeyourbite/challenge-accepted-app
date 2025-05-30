// lib/widgets/cards/streak_display_card.dart

import 'package:flutter/material.dart';

class StreakDisplayCard extends StatelessWidget {
  final int currentStreak;

  const StreakDisplayCard({
    super.key,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.red.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Streak',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentStreak 🔥',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentStreak > 0)
            Text(
              _getStreakMessage(currentStreak),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak >= 30) return "Legendary! 👑";
    if (streak >= 14) return "You're unstoppable! 💪";
    if (streak >= 7) return "One week strong! 🎯";
    if (streak >= 3) return "Keep it going! 🚀";
    return "Great start!";
  }
}