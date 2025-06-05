// File: lib/widgets/common/milestone_tracker.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/challenge_milestone.dart';

class MilestoneTracker extends StatelessWidget {
  final List<ChallengeMilestone> milestones;
  final String userId;
  final VoidCallback? onMilestoneDetail;
  
  const MilestoneTracker({
    super.key,
    required this.milestones,
    required this.userId,
    this.onMilestoneDetail,
  });
  
  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Milestones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onMilestoneDetail,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final isAchieved = milestone.achievedBy.any(
                (achievement) => achievement.userId == userId,
              );
              
              return _MilestoneCard(
                milestone: milestone,
                isAchieved: isAchieved,
                progress: _calculateProgress(milestone),
              );
            },
          ),
        ),
      ],
    );
  }
  
  double _calculateProgress(ChallengeMilestone milestone) {
    // This would be calculated based on current user stats
    // For now, returning a mock value
    return 0.65;
  }
}

class _MilestoneCard extends StatelessWidget {
  final ChallengeMilestone milestone;
  final bool isAchieved;
  final double progress;
  
  const _MilestoneCard({
    required this.milestone,
    required this.isAchieved,
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: isAchieved
            ? LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              )
            : null,
        color: isAchieved ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAchieved ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  milestone.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const Spacer(),
                if (isAchieved)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              milestone.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAchieved ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              milestone.description,
              style: TextStyle(
                fontSize: 12,
                color: isAchieved ? Colors.white70 : Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (!isAchieved)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}