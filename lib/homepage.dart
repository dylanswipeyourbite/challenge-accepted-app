import 'package:challengeaccepted/challenge_detail_page.dart';
import 'package:challengeaccepted/create_challenge.dart';
import 'package:challengeaccepted/graphql/mutations/challenge_mutations.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/graphql/subscriptions/challenge_subscriptions.dart';
import 'package:challengeaccepted/settings_page.dart';
import 'package:challengeaccepted/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
              child: const CircleAvatar(
                backgroundImage: NetworkImage('https://example.com/user-avatar.jpg'),
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
            const ActiveChallengesSection(),
            const SizedBox(height: 20),
            const PendingInvitesSection(),
            const SizedBox(height: 20),
            const TimelineFeedSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateChallengePage()),
          );
        },
        tooltip: 'Create Challenge',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        StatCard(label: "Streak", value: "5🔥"),
        StatCard(label: "Completed", value: "12"),
        StatCard(label: "PB", value: "5K in 23:42"),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
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

        // Wrap in Query for initial load
        Query(
          options: QueryOptions(
            document: gql(ChallengesQueries.getChallenges),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {fetchMore, refetch}) {

            if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
          

            if (result.hasException) {
              return Text('Error: ${result.exception.toString()}');
            }
            
            List challenges = result.data?['challenges'] ?? [];

            if (challenges.isEmpty) {
              return  Text("No pending challenges 🎉");
            }

            return Subscription(
              options: SubscriptionOptions(
                document: gql(ChallengeSubscriptions.challengeUpdated),
              ),
              builder: (subResult) {
                final updated = subResult.data?['challengeUpdated'];

                if (updated == null) {
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        return ChallengeCard(challenge: challenge);
                      },
                    ),
                  );
                }

                final index = challenges.indexWhere((c) => c['id'] == updated['id']);
                if (index != -1) {
                  challenges[index] = updated;
                } else {
                  challenges.insert(0, updated);
                }

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      return ChallengeCard(challenge: challenge);
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
  Future<void> showRestDayPickerDialog(BuildContext context, String challengeId, GraphQLClient client) async {
    await showDialog(
      context: context,
      builder: (context) {
        int selectedRestDays = 1; // moved outside StatefulBuilder

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
                    Navigator.of(context).pop(); // Close dialog first
                    await acceptChallengeInvite(client, challengeId, selectedRestDays);
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

  Future<void> acceptChallengeInvite(GraphQLClient client, String challengeId, int restDays) async {
  final MutationOptions options = MutationOptions(
    document: gql(ChallengeMutations.acceptChallenge),
    variables: {
      'challengeId': challengeId,
      'restDays': restDays,
    },
  );

  final result = await client.mutate(options);

  if (result.hasException) {
    print(result.exception.toString());
    // Show error toast/snackbar
  } else {
    print("Challenge joined!");
    // Optionally refresh challenge list or show success notification
  }
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

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.sports)),
                  title: Text(challenge['title']),
                  subtitle: Text("Time limit: ${challenge['timeLimit'].split('T')[0]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => showRestDayPickerDialog(context, challenge['id'], GraphQLProvider.of(context).value),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          // Optional: Add decline/counter offer logic
                        },
                      ),
                    ],
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


