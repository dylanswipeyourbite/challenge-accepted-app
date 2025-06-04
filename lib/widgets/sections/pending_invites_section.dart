import 'package:challengeaccepted/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/graphql/mutations/challenge_mutations.dart';
import 'package:challengeaccepted/widgets/dialogs/rest_day_picker_dialog.dart';
import 'package:challengeaccepted/widgets/dialogs/decline_challenge_dialog.dart';

class PendingInvitesSection extends StatelessWidget {
  const PendingInvitesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pending Invites",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer<ChallengeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.pendingChallenges.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.error != null) {
              return Text("Error: ${provider.error}");
            }

            if (provider.pendingChallenges.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "No pending invites 🎉",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.pendingChallenges.length,
              itemBuilder: (context, index) {
                final challenge = provider.pendingChallenges[index];
                return _PendingChallengeCard(challenge: challenge);
              },
            );
          },
        ),
      ],
    );
  }
}

class _PendingChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const _PendingChallengeCard({
    required this.challenge,
  });

  static const _sportIcons = {
    'running': Icons.directions_run,
    'cycling': Icons.directions_bike,
    'workout': Icons.fitness_center,
  };

  @override
  Widget build(BuildContext context) {
    final sport = challenge.sport;
    final createdBy = challenge.createdBy;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            _sportIcons[sport] ?? Icons.sports,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          challenge['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: _buildSubtitle(createdBy),
        isThreeLine: true,
        trailing: _buildActions(context),
      ),
    );
  }

  Widget _buildSubtitle(Map<String, dynamic>? createdBy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From: ${createdBy.displayName}",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          "Type: ${challenge.type} • Ends: ${(challenge['timeLimit'] as String).split('T')[0]}",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        if (challenge['wager'] != null && (challenge['wager'] as String).isNotEmpty)
          Text(
            "Wager: ${challenge.wager ?? ''}",
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => _handleAccept(context),
          tooltip: 'Accept',
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _handleDecline(context),
          tooltip: 'Decline',
        ),
      ],
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    final restDays = await showDialog<int>(
      context: context,
      builder: (context) => const RestDayPickerDialog(),
    );

    if (restDays == null || !context.mounted) return;

    final client = GraphQLProvider.of(context).value;
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(ChallengeMutations.acceptChallenge),
        variables: {
          'challengeId': challenge['id'],
          'restDays': restDays,
        },
      ),
    );

    if (!context.mounted) return;

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${result.exception?.graphqlErrors.first.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Challenge accepted! Good luck! 🔥'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh providers
      await context.read<ChallengeProvider>().refresh();
      await context.read<UserActivityProvider>().refresh();
    }
  }

  Future<void> _handleDecline(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => DeclineChallengeDialog(
        challengeTitle: challenge['title'] as String,
      ),
    );

    if (reason == null || !context.mounted) return;

    final client = GraphQLProvider.of(context).value;
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(ChallengeMutations.declineChallenge),
        variables: {
          'challengeId': challenge['id'],
          'reason': reason.isNotEmpty ? reason : null,
        },
      ),
    );

    if (!context.mounted) return;

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${result.exception?.graphqlErrors.first.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge declined'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Refresh providers
      await context.read<ChallengeProvider>().fetchPendingChallenges();
    }
  }
}