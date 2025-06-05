// 1. ENHANCED CHALLENGE CREATION
// File: lib/pages/create_challenge_page_v2.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/models/challenge_template.dart';
import 'package:challengeaccepted/widgets/forms/challenge_rules_editor.dart';

class CreateChallengePageV2 extends StatefulWidget {
  const CreateChallengePageV2({super.key});

  @override
  State<CreateChallengePageV2> createState() => _CreateChallengePageV2State();
}

class _CreateChallengePageV2State extends State<CreateChallengePageV2> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form data
  ChallengeTemplate? _selectedTemplate;
  String _title = '';
  String _description = '';
  String _rules = '';
  String _sport = 'workout';
  String _type = 'competitive';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _minWeeklyActivities = 4;
  int _minPointsToJoin = 0;
  int _creatorRestDays = 1;
  bool _requireDailyPhoto = false;
  List<String> _allowedActivities = ['running', 'cycling', 'workout', 'other'];
  final List<String> _selectedUserIds = [];
  String _wager = '';
  
  // Milestones
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
          title
          targetValue
          type
        }
      }
    }
  """;

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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _TemplateSelectionStep(),
          _BasicDetailsStep(),
          _RulesAndRequirementsStep(),
          _MilestonesStep(),
          _ReviewAndInviteStep(),
        ],
      ),
      bottomNavigationBar: _NavigationButtons(),
    );
  }
  
  Widget _TemplateSelectionStep() {
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
          _TemplateCard(
            template: null,
            isSelected: _selectedTemplate == null,
            onTap: () => setState(() => _selectedTemplate = null),
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
              child: _TemplateCard(
                template: template,
                isSelected: _selectedTemplate == template,
                onTap: () => setState(() {
                  _selectedTemplate = template;
                  _applyTemplate(template);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _BasicDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Challenge Title',
              hintText: 'e.g., Summer Fitness Challenge',
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
            onChanged: (val) => setState(() => _title = val),
            controller: TextEditingController(text: _title),
          ),
          const SizedBox(height: 16),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What is this challenge about?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
            onChanged: (val) => setState(() => _description = val),
            controller: TextEditingController(text: _description),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _SportSelector(
                  value: _sport,
                  onChanged: (val) => setState(() => _sport = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TypeSelector(
                  value: _type,
                  onChanged: (val) => setState(() => _type = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _DateRangePicker(
            startDate: _startDate,
            endDate: _endDate,
            onStartDateChanged: (date) => setState(() => _startDate = date),
            onEndDateChanged: (date) => setState(() => _endDate = date),
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
        ],
      ),
    );
  }
  
  Widget _RulesAndRequirementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Clear Expectations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Rules editor
          ChallengeRulesEditor(
            initialRules: _rules,
            onChanged: (rules) => setState(() => _rules = rules),
          ),
          const SizedBox(height: 16),
          
          // Activity requirements
          _RequirementCard(
            icon: Icons.calendar_today,
            title: 'Minimum Weekly Activities',
            child: _WeeklyActivitySlider(
              value: _minWeeklyActivities,
              onChanged: (val) => setState(() => _minWeeklyActivities = val),
            ),
          ),
          const SizedBox(height: 12),
          
          // Entry barrier
          _RequirementCard(
            icon: Icons.stars,
            title: 'Minimum Points to Join',
            subtitle: 'Filter for experienced users',
            child: _PointsRequirementSlider(
              value: _minPointsToJoin,
              onChanged: (val) => setState(() => _minPointsToJoin = val),
            ),
          ),
          const SizedBox(height: 12),
          
          // Creator rest days
          _RequirementCard(
            icon: Icons.bed,
            title: 'Your Rest Days per Week',
            child: _RestDaySelector(
              value: _creatorRestDays,
              onChanged: (val) => setState(() => _creatorRestDays = val),
            ),
          ),
          const SizedBox(height: 12),
          
          // Photo requirement
          _RequirementCard(
            icon: Icons.camera_alt,
            title: 'Daily Photo Required',
            child: Switch(
              value: _requireDailyPhoto,
              onChanged: (val) => setState(() => _requireDailyPhoto = val),
            ),
          ),
          const SizedBox(height: 12),
          
          // Allowed activities
          _RequirementCard(
            icon: Icons.sports,
            title: 'Allowed Activities',
            child: _ActivityTypeSelector(
              selectedActivities: _allowedActivities,
              onChanged: (activities) => setState(() => _allowedActivities = activities),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _MilestonesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Challenge Milestones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set goals for participants to achieve together or individually',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Suggested milestones
          if (_milestones.isEmpty) ...[
            const Text(
              'Suggested Milestones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _SuggestedMilestoneCard(
              title: 'First Week Champion',
              description: 'Log activities for 7 consecutive days',
              type: 'streak',
              targetValue: 7,
              onAdd: _addMilestone,
            ),
            _SuggestedMilestoneCard(
              title: 'Century Club',
              description: 'Earn 100 points in the challenge',
              type: 'points',
              targetValue: 100,
              onAdd: _addMilestone,
            ),
            _SuggestedMilestoneCard(
              title: 'Team Spirit',
              description: 'Everyone logs on the same day',
              type: 'custom',
              targetValue: 1,
              onAdd: _addMilestone,
            ),
          ],
          
          // Added milestones
          if (_milestones.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Your Milestones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._milestones.map((milestone) => _MilestoneCard(
              milestone: milestone,
              onEdit: () => _editMilestone(milestone),
              onDelete: () => _deleteMilestone(milestone),
            )),
          ],
          
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showAddMilestoneDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Custom Milestone'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _ReviewAndInviteStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Invite Friends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Challenge preview
          _ChallengePreviewCard(
            title: _title,
            description: _description,
            sport: _sport,
            type: _type,
            startDate: _startDate,
            endDate: _endDate,
            minWeeklyActivities: _minWeeklyActivities,
            milestones: _milestones,
            wager: _wager,
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Invite Participants',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          // Friend selector
          _FriendSelector(
            selectedUserIds: _selectedUserIds,
            onSelectionChanged: (ids) => setState(() => _selectedUserIds.clear()..addAll(ids)),
          ),
          
          const SizedBox(height: 24),
          _CreateChallengeButton(
            onPressed: _createChallenge,
          ),
        ],
      ),
    );
  }
  
  Widget _NavigationButtons() {
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
  
  void _applyTemplate(ChallengeTemplate template) {
    setState(() {
      _title = template.title;
      _description = template.description;
      _rules = template.rules;
      _minWeeklyActivities = template.minWeeklyActivities;
      _sport = template.sport;
      _allowedActivities = template.allowedActivities;
      _milestones.clear();
      _milestones.addAll(template.suggestedMilestones);
    });
  }
  
  void _addMilestone(String title, String description, String type, int targetValue) {
    setState(() {
      _milestones.add(ChallengeMilestone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        targetValue: targetValue,
        icon: _getMilestoneIcon(type),
      ));
    });
  }
  
  String _getMilestoneIcon(String type) {
    switch (type) {
      case 'points': return '🏆';
      case 'streak': return '🔥';
      case 'activities': return '💪';
      case 'custom': return '⭐';
      default: return '🎯';
    }
  }
  
  bool _canProceed() {
    switch (_currentStep) {
      case 0: return true; // Template selection
      case 1: return _title.isNotEmpty && _description.isNotEmpty;
      case 2: return _rules.isNotEmpty;
      case 3: return true; // Milestones are optional
      case 4: return _selectedUserIds.isNotEmpty;
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
    // Implementation of GraphQL mutation
    final client = GraphQLProvider.of(context).value;
    
    final input = {
      'title': _title,
      'description': _description,
      'rules': _rules,
      'sport': _sport,
      'type': _type,
      'startDate': _startDate.toIso8601String(),
      'timeLimit': _endDate.toIso8601String(),
      'minWeeklyActivities': _minWeeklyActivities,
      'minPointsToJoin': _minPointsToJoin,
      'creatorRestDays': _creatorRestDays,
      'requireDailyPhoto': _requireDailyPhoto,
      'allowedActivities': _allowedActivities,
      'participantIds': _selectedUserIds,
      'wager': _wager,
      'template': _selectedTemplate?.id,
      'milestones': _milestones.map((m) => m.toJson()).toList(),
    };
    
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
    }
  }
  
  void _showAddMilestoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMilestoneDialog(
        onAdd: (milestone) {
          setState(() => _milestones.add(milestone));
        },
      ),
    );
  }
  
  void _editMilestone(ChallengeMilestone milestone) {
    // Implementation
  }
  
  void _deleteMilestone(ChallengeMilestone milestone) {
    setState(() => _milestones.remove(milestone));
  }
}