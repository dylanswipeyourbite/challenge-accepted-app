import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateChallengePage extends StatelessWidget {
  const CreateChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Challenge')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CreateChallengeForm(),
      ),
    );
  }
}

class CreateChallengeForm extends StatefulWidget {
  const CreateChallengeForm({super.key});

  @override
  State<CreateChallengeForm> createState() => _CreateChallengeFormState();
}

class _CreateChallengeFormState extends State<CreateChallengeForm> {
final  String createChallengeMutation = """
  mutation CreateChallenge(\$input: CreateChallengeInput!) {
    createChallenge(input: \$input) {
      id
      title
      status
    }
  }
""";

  String _title = '';
  String _sport = 'running';
  String _type = 'competitive';
  DateTime _timeLimit = DateTime.now().add(const Duration(days: 3));
  String _wager = '';
  final List<String> _selectedUserIds = [];

  final List<String> mockUsers = ['user1', 'user2', 'user3'];

  @override
Widget build(BuildContext context) {
  return Mutation(
    options: MutationOptions(
      document: gql(createChallengeMutation),
      onCompleted: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Challenge created!")),
        );
        Navigator.of(context).pop(); // go back or reset form
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${error?.graphqlErrors.first.message}")),
        );
      },
    ),
    builder: (runMutation, result) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (val) => setState(() => _title = val),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _sport,
            items: ['running', 'cycling', 'workout'].map((sport) {
              return DropdownMenuItem(value: sport, child: Text(sport));
            }).toList(),
            onChanged: (val) => setState(() => _sport = val!),
            decoration: const InputDecoration(labelText: 'Sport'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Type:'),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Competitive'),
                selected: _type == 'competitive',
                onSelected: (_) => setState(() => _type = 'competitive'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Collaborative'),
                selected: _type == 'collaborative',
                onSelected: (_) => setState(() => _type = 'collaborative'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            title: Text('End date: ${_timeLimit.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _timeLimit,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _timeLimit = picked);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            decoration: const InputDecoration(labelText: 'Wager (optional)'),
            onChanged: (val) => setState(() => _wager = val),
          ),
          const SizedBox(height: 16),

          const Text('Select Opponents:'),
          ...mockUsers.map((userId) => CheckboxListTile(
                title: Text(userId),
                value: _selectedUserIds.contains(userId),
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _selectedUserIds.add(userId);
                    } else {
                      _selectedUserIds.remove(userId);
                    }
                  });
                },
              )),

          const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final input = {
                  "title": _title,
                  "sport": _sport,
                  "type": _type,
                  "timeLimit": _timeLimit.toUtc().toIso8601String(),
                  "wager": _wager,
                  "participantIds": _selectedUserIds,
                };
                runMutation({"input": input});
              },
              child: result?.isLoading ?? false
                  ? const CircularProgressIndicator()
                  : const Text('Create Challenge'),
            ),
          ],
        ),
      );
    },
  );
}
}
