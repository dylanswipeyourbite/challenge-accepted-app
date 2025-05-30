import 'package:challengeaccepted/challenge_detail_page.dart';
import 'package:challengeaccepted/create_challenge.dart';
import 'package:challengeaccepted/daily_activity_selector_page.dart'; // NEW
import 'package:challengeaccepted/graphql/mutations/challenge_mutations.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/graphql/subscriptions/challenge_subscriptions.dart';
import 'package:challengeaccepted/settings_page.dart';
import 'package:challengeaccepted/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/user_queries.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? 
                  'https://i.pravatar.cc/150?u=${FirebaseAuth.instance.currentUser?.uid}',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QuickStatsSection(),
            const SizedBox(height: 20),
            const QuickActionsSection(),
            const SizedBox(height: 20),
            const ActiveChallengesSection(),
            const SizedBox(height: 20),
            const PendingInvitesSection(),
            const SizedBox(height: 20),
            const TimelineFeedSection(),
          ],
        ),
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyActivitySelectorPage()),
              );
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Log Activity'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
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
          ),
        ),
      ],
    );
  }
}

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(UserQueries.getUserStats),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              StatCard(label: "Streak", value: "...", isLoading: true),
              StatCard(label: "Points", value: "...", isLoading: true),
              StatCard(label: "Next Goal", value: "...", isLoading: true),
            ],
          );
        }

        final stats = result.data?['userStats'];
        if (stats == null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              StatCard(label: "Streak", value: "0🔥"),
              StatCard(label: "Points", value: "0"),
              StatCard(label: "Challenges", value: "0"),
            ],
          );
        }

        final currentStreak = stats['currentStreak'] ?? 0;
        final totalPoints = stats['totalPoints'] ?? 0;
        final completedChallenges = stats['completedChallenges'] ?? 0;

        // Creative third stat: Show progress to next milestone
        String thirdStatValue;
        String thirdStatLabel;
        
        if (totalPoints < 100) {
          thirdStatValue = "${100 - totalPoints} to 💯";
          thirdStatLabel = "Next Milestone";
        } else if (totalPoints < 500) {
          thirdStatValue = "${500 - totalPoints} to 🏆";
          thirdStatLabel = "Gold Trophy";
        } else if (totalPoints < 1000) {
          thirdStatValue = "${1000 - totalPoints} to 👑";
          thirdStatLabel = "Champion";
        } else {
          thirdStatValue = "🌟 ${(totalPoints / 1000).toStringAsFixed(1)}K";
          thirdStatLabel = "Legend Status";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatCard(
              label: "Streak", 
              value: "$currentStreak${currentStreak > 0 ? '🔥' : ''}",
              subtitle: currentStreak > 7 ? "On fire!" : null,
            ),
            StatCard(
              label: "Points", 
              value: totalPoints.toString(),
              subtitle: completedChallenges > 0 ? "$completedChallenges won" : null,
            ),
            StatCard(
              label: thirdStatLabel, 
              value: thirdStatValue,
              isSpecial: true,
            ),
          ],
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool isLoading;
  final bool isSpecial;

  const StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.isLoading = false,
    this.isSpecial = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 85, // Fixed height for all cards
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSpecial
              ? LinearGradient(
                  colors: [Colors.purple.shade300, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSpecial ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSpecial ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSpecial ? Colors.white.withOpacity(0.9) : Colors.grey,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: isSpecial ? Colors.white.withOpacity(0.8) : Colors.green,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class ActiveChallengesSection extends StatelessWidget {
  const ActiveChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Active Challenges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Query(
          options: QueryOptions(
            document: gql(ChallengesQueries.getActiveChallenges),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Text('Error: ${result.exception.toString()}');
            }
            
            // Get current user from Firebase
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              return const Text("Not authenticated");
            }
            
            List challenges = result.data?['challenges'] ?? [];
            
            // Filter to show challenges where:
            // 1. User is a participant with 'accepted' status
            // 2. Challenge is not expired
            final activeChallenges = challenges.where((challenge) {
              // Skip expired challenges
              if (challenge['status'] == 'expired') return false;
              
              final participants = challenge['participants'] as List?;
              if (participants == null) return false;
              
              // Find if current user is an accepted participant
              final userParticipant = participants.firstWhere(
                (p) {
                  final participantUser = p['user'];
                  if (participantUser == null) return false;
                  
                  // Check if this participant is the current user AND has accepted
                  return participantUser['id'] != null && 
                         p['status'] == 'accepted';
                },
                orElse: () => null,
              );
              
              return userParticipant != null;
            }).toList();

            if (activeChallenges.isEmpty) {
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

            return Subscription(
              options: SubscriptionOptions(
                document: gql(ChallengeSubscriptions.challengeUpdated),
              ),
              builder: (subResult) {
                List displayChallenges = activeChallenges;
                
                final updated = subResult.data?['challengeUpdated'];
                if (updated != null) {
                  // Update the local list with the new data
                  final index = challenges.indexWhere((c) => c['id'] == updated['id']);
                  if (index != -1) {
                    challenges[index] = updated;
                  } else {
                    challenges.add(updated);
                  }
                  
                  // Re-filter for active challenges
                  displayChallenges = challenges.where((challenge) {
                    if (challenge['status'] == 'expired') return false;
                    
                    final participants = challenge['participants'] as List?;
                    if (participants == null) return false;
                    
                    final userParticipant = participants.firstWhere(
                      (p) {
                        final participantUser = p['user'];
                        if (participantUser == null) return false;
                        return participantUser['id'] != null && p['status'] == 'accepted';
                      },
                      orElse: () => null,
                    );
                    
                    return userParticipant != null;
                  }).toList();
                }

                return SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = displayChallenges[index];
                      return ActiveChallengeCard(challenge: challenge);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ActiveChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ActiveChallengeCard({required this.challenge, super.key});

  @override
  Widget build(BuildContext context) {
    final participants = challenge['participants'] as List? ?? [];
    final acceptedCount = participants.where((p) => p['status'] == 'accepted').length;
    final status = challenge['status'] ?? 'pending';
    
    // Determine status color and text
    Color statusColor;
    String statusText;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'ACTIVE';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'STARTING SOON';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'COMPLETED';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
    }
    
    // Calculate days remaining
    final timeLimit = DateTime.tryParse(challenge['timeLimit'] ?? '');
    final daysRemaining = timeLimit?.difference(DateTime.now()).inDays ?? 0;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailPage(challenge: challenge),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        elevation: 3,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and type
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    challenge['type'] == 'competitive' 
                        ? Icons.emoji_events 
                        : Icons.group,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              Expanded(
                child: Text(
                  challenge['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Bottom info section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        "$acceptedCount participants",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (daysRemaining > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          "$daysRemaining days left",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                  if (challenge['wager'] != null && challenge['wager'].isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.local_offer, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            challenge['wager'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeCard({required this.challenge, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailPage(challenge: challenge),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Type: ${challenge['type']}", style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Text("Status: ${challenge['status']}", style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ),
    );
  }
}

class PendingInvitesSection extends StatelessWidget {
  Future<void> showRestDayPickerDialog(BuildContext context, String challengeId, VoidCallback? refetch) async {
    await showDialog(
      context: context,
      builder: (context) {
        int selectedRestDays = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Challenge'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rest days are essential in every challenge. Please select how many rest days you want for this challenge.',
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<int>(
                    value: selectedRestDays,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRestDays = value;
                        });
                      }
                    },
                    items: List.generate(7, (index) => index).map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value rest day${value != 1 ? 's' : ''}'),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final client = GraphQLProvider.of(context).value;
                    await acceptChallengeInvite(context, client, challengeId, selectedRestDays, refetch);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showDeclineDialog(BuildContext context, String challengeId, String challengeTitle, VoidCallback? refetch) async {
    await showDialog(
      context: context,
      builder: (context) {
        String declineReason = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Decline Challenge'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to decline "$challengeTitle"?'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      hintText: 'Let them know why you\'re declining...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      declineReason = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final client = GraphQLProvider.of(context).value;
                    await declineChallengeInvite(context, client, challengeId, declineReason, refetch);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Decline'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> acceptChallengeInvite(BuildContext context, GraphQLClient client, String challengeId, int restDays, VoidCallback? refetch) async {
    final MutationOptions options = MutationOptions(
      document: gql(ChallengeMutations.acceptChallenge),
      variables: {
        'challengeId': challengeId,
        'restDays': restDays,
      },
      onCompleted: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Challenge accepted! Good luck! 🔥'),
            backgroundColor: Colors.green,
          ),
        );
        refetch?.call();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${error?.graphqlErrors.first.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    await client.mutate(options);
  }

  Future<void> declineChallengeInvite(BuildContext context, GraphQLClient client, String challengeId, String reason, VoidCallback? refetch) async {
    final MutationOptions options = MutationOptions(
      document: gql(ChallengeMutations.declineChallenge),
      variables: {
        'challengeId': challengeId,
        'reason': reason.isNotEmpty ? reason : null,
      },
      onCompleted: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge declined'),
            backgroundColor: Colors.orange,
          ),
        );
        refetch?.call();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${error?.graphqlErrors.first.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    await client.mutate(options);
  }

  const PendingInvitesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pending Invites", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Query(
          options: QueryOptions(
            document: gql(ChallengesQueries.pendingChallenges),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {refetch, fetchMore}) {
            if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (result.hasException) {
              return Text("Error: ${result.exception.toString()}");
            }

            final List challenges = result.data?['pendingChallenges'] ?? [];

            if (challenges.isEmpty) {
              return const Text("No pending invites 🎉");
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                final createdBy = challenge['createdBy'];
                final sport = challenge['sport'] ?? 'workout';
                final sportIcons = {
                  'running': Icons.directions_run,
                  'cycling': Icons.directions_bike,
                  'workout': Icons.fitness_center,
                };

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        sportIcons[sport] ?? Icons.sports,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      challenge['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From: ${createdBy?['displayName'] ?? 'Unknown'}",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          "Type: ${challenge['type']} • Ends: ${challenge['timeLimit'].split('T')[0]}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        if (challenge['wager'] != null && challenge['wager'].isNotEmpty)
                          Text(
                            "Wager: ${challenge['wager']}",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => showRestDayPickerDialog(
                            context, 
                            challenge['id'],
                            refetch
                          ),
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => showDeclineDialog(
                            context,
                            challenge['id'],
                            challenge['title'],
                            refetch
                          ),
                          tooltip: 'Decline',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class TimelineFeedSection extends StatelessWidget {
  const TimelineFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getTimelineMedia),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Text('Error: ${result.exception.toString()}');
        }

        final List mediaList = result.data?['timelineMedia'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text("Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];

                return PostCard(
                  mediaId: media['id'],
                  imageUrl: media['url'],
                  displayName: media['user']['displayName'],
                  avatarUrl: media['user']['avatarUrl'],
                  cheers: media['cheers'],
                  comments: media['comments'],
                  hasCheered: media['hasCheered'],
                  onRefetch: refetch,
                  caption: media['caption']
                );
              },
            )
          ],
        );
      },
    );
  }
}


