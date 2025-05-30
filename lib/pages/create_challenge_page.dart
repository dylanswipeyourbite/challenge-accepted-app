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
  final String createChallengeMutation = """
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
  DateTime _startDate = DateTime.now();
  DateTime _timeLimit = DateTime.now().add(const Duration(days: 30));
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
                decoration: const InputDecoration(
                  labelText: 'Challenge Title',
                  hintText: 'e.g., Summer 5K Challenge',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _title = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _sport,
                decoration: const InputDecoration(
                  labelText: 'Sport',
                  border: OutlineInputBorder(),
                ),
                items: ['running', 'cycling', 'workout'].map((sport) {
                  final icons = {
                    'running': Icons.directions_run,
                    'cycling': Icons.directions_bike,
                    'workout': Icons.fitness_center,
                  };
                  return DropdownMenuItem(
                    value: sport,
                    child: Row(
                      children: [
                        Icon(icons[sport], size: 20),
                        const SizedBox(width: 8),
                        Text(sport.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _sport = val!),
              ),
              const SizedBox(height: 16),

              const Text('Challenge Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.emoji_events, size: 18),
                          SizedBox(width: 4),
                          Text('Competitive'),
                        ],
                      ),
                      selected: _type == 'competitive',
                      onSelected: (_) => setState(() => _type = 'competitive'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.group, size: 18),
                          SizedBox(width: 4),
                          Text('Collaborative'),
                        ],
                      ),
                      selected: _type == 'collaborative',
                      onSelected: (_) => setState(() => _type = 'collaborative'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // START DATE PICKER
              Card(
                child: ListTile(
                  leading: const Icon(Icons.play_circle_outline, color: Colors.green),
                  title: const Text('Start Date'),
                  subtitle: Text(
                    '${_startDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        // Ensure end date is after start date
                        if (_timeLimit.isBefore(_startDate)) {
                          _timeLimit = _startDate.add(const Duration(days: 30));
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // END DATE PICKER
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag, color: Colors.red),
                  title: const Text('End Date'),
                  subtitle: Text(
                    '${_timeLimit.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _timeLimit,
                      firstDate: _startDate.add(const Duration(days: 1)),
                      lastDate: _startDate.add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _timeLimit = picked);
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Duration display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_timeLimit.difference(_startDate).inDays} days',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Wager (optional)',
                  hintText: 'e.g., Loser buys coffee ☕',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                ),
                onChanged: (val) => setState(() => _wager = val),
              ),
              const SizedBox(height: 16),

              const Text(
                'Select Participants',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: mockUsers.map((userId) => CheckboxListTile(
                    title: Text(userId),
                    subtitle: Text('Last active: 2 days ago'),
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
                  )).toList(),
                ),
              ),

              const SizedBox(height: 24),
              
              // Challenge preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Challenge Preview',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('📍 ${_sport.toUpperCase()} • ${_type.toUpperCase()}'),
                    Text('📅 Starts: ${_startDate.toLocal().toString().split(' ')[0]}'),
                    Text('🏁 Ends: ${_timeLimit.toLocal().toString().split(' ')[0]}'),
                    Text('👥 ${_selectedUserIds.length + 1} participants (including you)'),
                    if (_wager.isNotEmpty) Text('🎯 Wager: $_wager'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _title.isEmpty || _selectedUserIds.isEmpty
                      ? null
                      : () {
                          final input = {
                            "title": _title,
                            "sport": _sport,
                            "type": _type,
                            "startDate": _startDate.toUtc().toIso8601String(),
                            "timeLimit": _timeLimit.toUtc().toIso8601String(),
                            "wager": _wager,
                            "participantIds": _selectedUserIds,
                          };
                          runMutation({"input": input});
                        },
                  child: result?.isLoading ?? false
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Challenge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}