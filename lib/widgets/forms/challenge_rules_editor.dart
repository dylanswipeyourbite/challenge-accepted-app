import 'package:flutter/material.dart';

class ChallengeRulesEditor extends StatefulWidget {
  final List<String> rules;
  final Function(List<String>) onRulesChanged;

  const ChallengeRulesEditor({
    Key? key,
    required this.rules,
    required this.onRulesChanged,
  }) : super(key: key);

  @override
  State<ChallengeRulesEditor> createState() => _ChallengeRulesEditorState();
}

class _ChallengeRulesEditorState extends State<ChallengeRulesEditor> {
  late List<String> _rules;
  final _ruleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rules = List.from(widget.rules);
  }

  void _addRule() {
    if (_ruleController.text.isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text);
        widget.onRulesChanged(_rules);
        _ruleController.clear();
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
      widget.onRulesChanged(_rules);
    });
  }

  void _editRule(int index) {
    final controller = TextEditingController(text: _rules[index]);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Rule'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rule',
            hintText: 'Enter rule description',
          ),
          maxLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _rules[index] = controller.text;
                  widget.onRulesChanged(_rules);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add rule input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ruleController,
                decoration: const InputDecoration(
                  hintText: 'Add a rule...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addRule(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addRule,
              tooltip: 'Add Rule',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Rules list
        if (_rules.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rule_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No rules added yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add rules to define how the challenge works',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_rules.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_rules[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editRule(index),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeRule(index),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          }),
        
        // Suggested rules
        const SizedBox(height: 24),
        const Text(
          'Suggested Rules',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSuggestedRuleChip('Complete at least one activity per day'),
            _buildSuggestedRuleChip('Activities must be at least 30 minutes'),
            _buildSuggestedRuleChip('Submit proof (photo/video) for each activity'),
            _buildSuggestedRuleChip('No make-up days allowed'),
            _buildSuggestedRuleChip('All activities must be logged within 24 hours'),
            _buildSuggestedRuleChip('Rest days count as 0 points'),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestedRuleChip(String rule) {
    final isAdded = _rules.contains(rule);
    
    return ActionChip(
      label: Text(rule),
      backgroundColor: isAdded ? Colors.green.shade100 : null,
      avatar: Icon(
        isAdded ? Icons.check : Icons.add,
        size: 18,
      ),
      onPressed: isAdded
          ? null
          : () {
              setState(() {
                _rules.add(rule);
                widget.onRulesChanged(_rules);
              });
            },
    );
  }

  @override
  void dispose() {
    _ruleController.dispose();
    super.dispose();
  }
}