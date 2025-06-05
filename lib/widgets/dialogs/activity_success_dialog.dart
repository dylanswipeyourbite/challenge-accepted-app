// lib/widgets/dialogs/activity_success_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/models/challenge.dart';

class ActivitySuccessDialog extends StatelessWidget {
  final int pointsEarned;
  final int newStreak;
  final String challengeTitle;
  final VoidCallback onComplete;
  final bool isLastChallenge; // Used in multi-challenge flow

  const ActivitySuccessDialog({
    super.key,
    required this.pointsEarned,
    required this.newStreak,
    required this.challengeTitle,
    required this.onComplete,
    this.isLastChallenge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getActiveChallenges),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {refetch, fetchMore}) {
        final remainingChallenges = _calculateRemainingChallenges(result.data);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(remainingChallenges),
                _buildActions(context, remainingChallenges),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            _getMotivationalTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int remainingChallenges) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Points and streak info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                icon: Icons.star,
                value: '+$pointsEarned',
                label: 'Points',
                color: Colors.amber,
              ),
              if (newStreak > 0)
                _StatCard(
                  icon: Icons.local_fire_department,
                  value: '$newStreak',
                  label: 'Day Streak',
                  color: Colors.orange,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Challenge completion info
          Text(
            'Completed: $challengeTitle',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Remaining challenges or completion message
          if (remainingChallenges > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '$remainingChallenges more to go today!',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRemainingChallengesMessage(remainingChallenges),
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.purple,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All done for today!',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You\'ve crushed all your challenges! 🎉\nTime to inspire your friends!',
                    style: TextStyle(color: Colors.purple, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, int remainingChallenges) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Inspire friends button
          _InspireFriendsButton(onPressed: () => _sendInspiration(context)),

          const SizedBox(height: 12),

          // Primary action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onComplete();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    remainingChallenges > 0 ? Colors.green : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                remainingChallenges > 0
                    ? isLastChallenge
                        ? 'Continue to Next Challenge'
                        : 'Back to Home'
                    : 'Back to Home',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalTitle() {
    final titles = [
      'Amazing Work! 💪',
      'You\'re Crushing It! 🔥',
      'Keep That Momentum! 🚀',
      'Consistency Champion! 🏆',
      'Way to Show Up! ⭐',
    ];

    // Use points as a simple way to vary the message
    return titles[pointsEarned % titles.length];
  }

  String _getRemainingChallengesMessage(int remaining) {
    if (remaining == 1) {
      return 'Just one more challenge to complete your perfect day!';
    } else if (remaining <= 3) {
      return 'You\'re so close to a perfect day! Keep pushing!';
    } else {
      return 'Keep the momentum going! Your friends are counting on you!';
    }
  }

  int _calculateRemainingChallenges(Map<String, dynamic>? data) {
    if (data == null) return 0;

    final challengesData = data['challenges'] ?? [];
    int remaining = 0;

    for (final challengeJson in challengesData) {
      try {
        final challenge = Challenge.fromJson(challengeJson);

        // Skip expired challenges
        if (challenge.isExpired) continue;

        // Check if current user is an accepted participant
        final currentUserParticipant = challenge.currentUserParticipant;
        if (currentUserParticipant == null ||
            !currentUserParticipant.isAccepted) {
          continue;
        }

        // Check if user has logged today
        if (!challenge.hasCurrentUserLogged) {
          remaining++;
        }
      } catch (_) {
        continue;
      }
    }

    return remaining;
  }

  Future<void> _sendInspiration(BuildContext context) async {
    // Show bottom sheet with friend selection
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _InspireFriendsSheet(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}

class _InspireFriendsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _InspireFriendsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.favorite, size: 20),
      label: const Text('Send Inspiration to Friends'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: Colors.pink.shade300, width: 2),
        foregroundColor: Colors.pink.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _InspireFriendsSheet extends StatefulWidget {
  const _InspireFriendsSheet();

  @override
  State<_InspireFriendsSheet> createState() => _InspireFriendsSheetState();
}

class _InspireFriendsSheetState extends State<_InspireFriendsSheet> {
  final Set<String> selectedFriends = {};
  String selectedMessage = 'Keep going! You got this! 💪';

  final List<String> inspirationalMessages = [
    'Keep going! You got this! 💪',
    'Your consistency is inspiring! 🔥',
    'One day at a time, one rep at a time! 🏋️',
    'The only bad workout is the one you didn\'t do! 🏃',
    'Champions are made one day at a time! 🏆',
    'Your future self will thank you! 🌟',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Send Inspiration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Message selection
          const Text(
            'Choose a message:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: inspirationalMessages.length,
              itemBuilder: (context, index) {
                final message = inspirationalMessages[index];
                final isSelected = selectedMessage == message;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedMessage = message;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.pink.shade50
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.pink.shade300
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          message,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.pink.shade700
                                    : Colors.grey.shade700,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  selectedMessage.isNotEmpty
                      ? () => _sendInspiration(context)
                      : null,
              icon: const Icon(Icons.send),
              label: const Text('Send Inspiration'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendInspiration(BuildContext context) {
    // TODO: Implement actual push notification sending
    // For now, just show a success message

    HapticFeedback.mediumImpact();

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Inspiration sent to your challenge buddies!'),
          ],
        ),
        backgroundColor: Colors.pink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
