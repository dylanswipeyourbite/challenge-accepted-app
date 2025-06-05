import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:challengeaccepted/models/challenge_template.dart';
import 'package:challengeaccepted/models/challenge_milestone.dart';
import 'package:challengeaccepted/widgets/forms/challenge_rules_editor.dart';

class CreateChallengePageV2 extends StatefulWidget {
  const CreateChallengePageV2({super.key});

  @override
  State<CreateChallengePageV2> createState() => _CreateChallengePageV2State();
}

class _CreateChallengePageV2State extends State<CreateChallengePageV2> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minPointsController = TextEditingController();
  final TextEditingController _restDaysController = TextEditingController(text: '2');
  final TextEditingController _wagerController = TextEditingController();
  
  // Form data with proper types
  ChallengeTemplate? _selectedTemplate;
  List<String> _rules = [];
  String _sport = 'workout';
  String _type = 'competitive';
  DateTime? _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 30));
  int _minWeeklyActivities = 4;
  int _minPointsToJoin = 0;
  int _creatorRestDays = 1;
  bool _requireDailyPhoto = false;
  bool _allowRestDays = true;
  List<String> _allowedActivities = ['Running', 'Cycling', 'Gym', 'Other'];
  final List<String> _selectedUserIds = [];
  final List<ChallengeMilestone> _milestones = [];

  static const String createChallengeMutation = """
    mutation CreateChallengeV2(\$input: CreateChallengeInputV2!) {
      createChallengeV2(input: \$input) {
        id
        title
        description
        status
        milestones {
          id
          name
          target
          type
        }
      }
    }
  """;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minPointsController.dispose();
    _restDaysController.dispose();
    _wagerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Challenge (Step ${_currentStep + 1}/5)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildTemplateSelectionStep(),
            _buildBasicInfoStep(),
            _buildRulesStep(),
            _buildRequirementsStep(),
            _buildReviewStep(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }
  
  Widget _buildTemplateSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose a Template or Start Fresh',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Templates help you get started quickly with proven challenge formats',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Custom challenge option
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _selectedTemplate == null 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              title: const Text('Custom Challenge'),
              subtitle: const Text('Create your own unique challenge'),
              selected: _selectedTemplate == null,
              onTap: () => setState(() => _selectedTemplate = null),
            ),
          ),
          
          const SizedBox(height: 16),
          const Text(
            'Popular Templates',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          ...ChallengeTemplate.popularTemplates.map((template) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _selectedTemplate == template 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey.shade300,
                    child: Icon(template.icon, color: Colors.white),
                  ),
                  title: Text(template.name),
                  subtitle: Text(template.description),
                  selected: _selectedTemplate == template,
                  onTap: () => setState(() {
                    _selectedTemplate = template;
                    _applyTemplate(template);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Challenge Name',
              hintText: 'e.g., 30-Day Fitness Challenge',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a challenge name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your challenge...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Select date',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Select date',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _sport,
            decoration: const InputDecoration(
              labelText: 'Sport Category',
              border: OutlineInputBorder(),
            ),
            items: ['workout', 'running', 'cycling', 'swimming', 'yoga', 'other']
                .map((sport) => DropdownMenuItem(
                      value: sport,
                      child: Text(sport[0].toUpperCase() + sport.substring(1)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _sport = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Challenge Type',
              border: OutlineInputBorder(),
            ),
            items: ['competitive', 'collaborative', 'personal']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wagerController,
            decoration: const InputDecoration(
              labelText: 'Wager (optional)',
              hintText: 'e.g., Loser buys coffee ☕',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_offer),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRulesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenge Rules',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ChallengeRulesEditor(
            rules: _rules,
            onRulesChanged: (rules) {
              setState(() {
                _rules = rules;
              });
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minimum Weekly Activities',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minWeeklyActivities.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          label: _minWeeklyActivities.toString(),
                          onChanged: (value) {
                            setState(() {
                              _minWeeklyActivities = value.round();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '$_minWeeklyActivities/week',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Creator Rest Days per Week',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _creatorRestDays.toDouble(),
                          min: 0,
                          max: 3,
                          divisions: 3,
                          label: _creatorRestDays.toString(),
                          onChanged: (value) {
                            setState(() {
                              _creatorRestDays = value.round();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '$_creatorRestDays days',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Require Daily Photo'),
              subtitle: const Text('Participants must submit photo proof'),
              value: _requireDailyPhoto,
              onChanged: (value) {
                setState(() {
                  _requireDailyPhoto = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements & Restrictions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minimum Points to Join',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _minPointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                      helperText: 'Leave empty for no minimum',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _minPointsToJoin = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allowed Activity Types',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Running',
                      'Cycling',
                      'Swimming',
                      'Gym',
                      'Yoga',
                      'Walking',
                      'Other'
                    ].map((activity) {
                      final isSelected = _allowedActivities.contains(activity);
                      return FilterChip(
                        label: Text(activity),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _allowedActivities.add(activity);
                            } else {
                              _allowedActivities.remove(activity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Allow Rest Days'),
              subtitle: const Text('Participants can mark days as rest days'),
              value: _allowRestDays,
              onChanged: (value) {
                setState(() {
                  _allowRestDays = value;
                });
              },
            ),
          ),
          if (_allowRestDays) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rest Days per Week',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _restDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '2',
                        helperText: 'Maximum rest days allowed per week',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Milestones',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _showMilestoneDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_milestones.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No milestones added yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showMilestoneDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Milestone'),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_milestones.length, (index) {
              final milestone = _milestones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(milestone.name),
                  subtitle: Text(
                    '${milestone.type} - Target: ${milestone.target}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _milestones.removeAt(index);
                      });
                    },
                  ),
                  onTap: () => _showMilestoneDialog(index: index),
                ),
              );
            }),
        ],
      ),
    );
  }
  
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Challenge',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildReviewCard(
            'Basic Information',
            [
              _buildReviewItem('Name', _nameController.text),
              _buildReviewItem('Description', _descriptionController.text),
              _buildReviewItem(
                'Duration',
                _startDate != null && _endDate != null
                    ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                    : 'Not set',
              ),
              _buildReviewItem('Sport', _sport),
              _buildReviewItem('Type', _type),
              if (_wagerController.text.isNotEmpty)
                _buildReviewItem('Wager', _wagerController.text),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Rules',
            _rules.isNotEmpty
                ? _rules.map((rule) => _buildReviewItem('', '• $rule')).toList()
                : [_buildReviewItem('', 'No rules added')],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Requirements',
            [
              _buildReviewItem(
                'Minimum Points',
                _minPointsController.text.isEmpty
                    ? 'None'
                    : _minPointsController.text,
              ),
              _buildReviewItem(
                'Weekly Activities',
                '$_minWeeklyActivities per week',
              ),
              _buildReviewItem(
                'Activity Types',
                _allowedActivities.isEmpty
                    ? 'All types allowed'
                    : _allowedActivities.join(', '),
              ),
              _buildReviewItem(
                'Rest Days',
                _allowRestDays
                    ? '${_restDaysController.text} per week'
                    : 'Not allowed',
              ),
              _buildReviewItem(
                'Daily Photo',
                _requireDailyPhoto ? 'Required' : 'Not required',
              ),
              _buildReviewItem(
                'Creator Rest Days',
                '$_creatorRestDays per week',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Milestones',
            _milestones.isNotEmpty
                ? _milestones
                    .map((m) => _buildReviewItem(
                          m.name,
                          '${m.type} - Target: ${m.target}',
                        ))
                    .toList()
                : [_buildReviewItem('', 'No milestones added')],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              child: Text(_currentStep < 4 ? 'Next' : 'Create Challenge'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewCard(String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
void _applyTemplate(ChallengeTemplate template) {
  setState(() {
    _nameController.text = template.name;  // 'name' maps to 'title' in the form
    _descriptionController.text = template.description;
    _rules = List.from(template.defaultRules);  // 'defaultRules' maps to 'rules'
    _allowedActivities = List.from(template.activityTypes);  // 'activityTypes' maps to 'allowedActivities'
    _milestones.clear();
    _milestones.addAll(template.suggestedMilestones);
    
    // Add these new mappings:
    _minWeeklyActivities = template.minWeeklyActivities;
    _sport = template.sport;
    _type = template.type;
    
    // Set duration based on template
    _endDate = _startDate?.add(Duration(days: template.suggestedDuration));
    
    if (template.suggestedRestDaysPerWeek != null) {
      _restDaysController.text = template.suggestedRestDaysPerWeek.toString();
      _allowRestDays = true;
    }
  });
}
  
  void _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Auto-set end date to 30 days later if not set
          if (_endDate == null) {
            _endDate = picked.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  void _showMilestoneDialog({int? index}) {
    final isEditing = index != null;
    final milestone = isEditing ? _milestones[index] : null;
    
    final nameController = TextEditingController(text: milestone?.name ?? '');
    final targetController = TextEditingController(
      text: milestone?.target.toString() ?? '',
    );
    final descriptionController = TextEditingController(text: milestone?.description ?? '');
    String type = milestone?.type ?? 'points';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Milestone' : 'Add Milestone'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Milestone Name',
                  hintText: 'e.g., First Week Complete',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Describe the milestone',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: ['points', 'streak', 'activities', 'custom']
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t[0].toUpperCase() + t.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    type = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                  hintText: 'e.g., 100',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  targetController.text.isNotEmpty) {
                setState(() {
                  final newMilestone = ChallengeMilestone(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    type: type,
                    target: int.tryParse(targetController.text) ?? 0,
                    description: descriptionController.text.isEmpty 
                        ? null 
                        : descriptionController.text,
                  );
                  
                  if (isEditing) {
                    _milestones[index] = newMilestone;
                  } else {
                    _milestones.add(newMilestone);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  bool _canProceed() {
    switch (_currentStep) {
      case 0: return true; // Template selection
      case 1: return _nameController.text.isNotEmpty;
      case 2: return _rules.isNotEmpty;
      case 3: return true; // Requirements are optional
      case 4: return true; // Review
      default: return false;
    }
  }
  
  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _createChallenge();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }
  
  Future<void> _createChallenge() async {
    final client = GraphQLProvider.of(context).value;
    
    // In _createChallenge method, ensure the input object uses correct field names:
    final input = {
      'title': _nameController.text,  // Not 'name'
      'description': _descriptionController.text,
      'rules': _rules,  // List<String>
      'sport': _sport,
      'type': _type,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),  // Change from 'timeLimit'
      'minWeeklyActivities': _minWeeklyActivities,
      'minPointsToJoin': _minPointsToJoin,
      'creatorRestDays': _creatorRestDays,
      'requireDailyPhoto': _requireDailyPhoto,
      'allowedActivities': _allowedActivities,  // List<String>
      'allowRestDays': _allowRestDays,
      'restDaysPerWeek': int.tryParse(_restDaysController.text) ?? 2,
      'wager': _wagerController.text,
      'templateId': _selectedTemplate?.id,  // Change from 'template'
      'milestones': _milestones.map((m) => m.toMap()).toList(),
      'participantIds': _selectedUserIds,  // Add this if not present
    };
    
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(createChallengeMutation),
          variables: {'input': input},
        ),
      );
      
      if (!result.hasException && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Challenge created successfully!')),
        );
      } else if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.exception.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}