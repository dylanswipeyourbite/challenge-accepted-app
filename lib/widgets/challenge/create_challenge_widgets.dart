// File: lib/widgets/challenge/create_challenge_widgets.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/challenge_template.dart';
import 'package:challengeaccepted/models/challenge_milestone.dart';
import 'package:intl/intl.dart';

// Template selection card
class TemplateCard extends StatelessWidget {
  final ChallengeTemplate? template;
  final bool isSelected;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                child: Icon(
                  template?.icon ?? Icons.edit,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template?.name ?? 'Custom Challenge',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template?.description ?? 'Create your own unique challenge',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (template != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${template!.suggestedDuration} days',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.flag, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${template!.suggestedMilestones.length} milestones',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sport selector dropdown
class SportSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const SportSelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sports = {
      'workout': {'icon': Icons.fitness_center, 'label': 'Workout'},
      'running': {'icon': Icons.directions_run, 'label': 'Running'},
      'cycling': {'icon': Icons.directions_bike, 'label': 'Cycling'},
      'swimming': {'icon': Icons.pool, 'label': 'Swimming'},
      'yoga': {'icon': Icons.self_improvement, 'label': 'Yoga'},
      'other': {'icon': Icons.sports, 'label': 'Other'},
    };

    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Sport',
        border: OutlineInputBorder(),
      ),
      items: sports.entries.map((entry) => DropdownMenuItem(
        value: entry.key,
        child: Row(
          children: [
            Icon(entry.value['icon'] as IconData, size: 20),
            const SizedBox(width: 8),
            Text(entry.value['label'] as String),
          ],
        ),
      )).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

// Challenge type selector
class TypeSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const TypeSelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'competitive', child: Text('Competitive')),
        DropdownMenuItem(value: 'collaborative', child: Text('Collaborative')),
      ],
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

// Date range picker
class DateRangePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const DateRangePicker({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Start Date',
                date: startDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) onStartDateChanged(date);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DateField(
                label: 'End Date',
                date: endDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: startDate.add(const Duration(days: 365)),
                  );
                  if (date != null) onEndDateChanged(date);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${endDate.difference(startDate).inDays} days',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(date)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}

// Requirement card
class RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const RequirementCard({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// Weekly activity slider
class WeeklyActivitySlider extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const WeeklyActivitySlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: value.toString(),
          onChanged: (val) => onChanged(val.round()),
        ),
        Text(
          '$value activities per week',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Points requirement slider
class PointsRequirementSlider extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const PointsRequirementSlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 1000,
          divisions: 20,
          label: value.toString(),
          onChanged: (val) => onChanged(val.round()),
        ),
        Text(
          value == 0 ? 'No minimum' : '$value points required',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Rest day selector
class RestDaySelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const RestDaySelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return ChoiceChip(
          label: Text('$index'),
          selected: value == index,
          onSelected: (selected) {
            if (selected) onChanged(index);
          },
        );
      }),
    );
  }
}

// Activity type selector
class ActivityTypeSelector extends StatelessWidget {
  final List<String> selectedActivities;
  final Function(List<String>) onChanged;

  const ActivityTypeSelector({
    Key? key,
    required this.selectedActivities,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activities = [
      'Running', 'Cycling', 'Swimming', 'Gym', 
      'Yoga', 'Walking', 'Hiking', 'Other'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: activities.map((activity) {
        final isSelected = selectedActivities.contains(activity);
        return FilterChip(
          label: Text(activity),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<String>.from(selectedActivities);
            if (selected) {
              updated.add(activity);
            } else {
              updated.remove(activity);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// Suggested milestone card
class SuggestedMilestoneCard extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final int targetValue;
  final Function(String, String, String, int) onAdd;

  const SuggestedMilestoneCard({
    Key? key,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMilestoneColor(type).withOpacity(0.2),
          child: Icon(
            _getMilestoneIcon(type),
            color: _getMilestoneColor(type),
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onAdd(title, description, type, targetValue),
        ),
      ),
    );
  }

  IconData _getMilestoneIcon(String type) {
    switch (type) {
      case 'points':
        return Icons.stars;
      case 'streak':
        return Icons.local_fire_department;
      case 'activities':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }

  Color _getMilestoneColor(String type) {
    switch (type) {
      case 'points':
        return Colors.amber;
      case 'streak':
        return Colors.orange;
      case 'activities':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}

// Milestone card
class MilestoneCard extends StatelessWidget {
  final ChallengeMilestone milestone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MilestoneCard({
    Key? key,
    required this.milestone,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMilestoneColor(milestone.type).withOpacity(0.2),
          child: Icon(
            _getMilestoneIcon(milestone.type),
            color: _getMilestoneColor(milestone.type),
          ),
        ),
        title: Text(milestone.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (milestone.description != null)
              Text(milestone.description!),
            const SizedBox(height: 4),
            Text(
              'Target: ${milestone.target} ${milestone.type}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMilestoneIcon(String type) {
    switch (type) {
      case 'points':
        return Icons.stars;
      case 'streak':
        return Icons.local_fire_department;
      case 'activities':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }

  Color _getMilestoneColor(String type) {
    switch (type) {
      case 'points':
        return Colors.amber;
      case 'streak':
        return Colors.orange;
      case 'activities':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}

// Challenge preview card
class ChallengePreviewCard extends StatelessWidget {
  final String title;
  final String description;
  final String sport;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final int minWeeklyActivities;
  final List<ChallengeMilestone> milestones;
  final String? wager;

  const ChallengePreviewCard({
    Key? key,
    required this.title,
    required this.description,
    required this.sport,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.minWeeklyActivities,
    required this.milestones,
    this.wager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isEmpty ? 'Challenge Preview' : title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.sports,
                  label: sport[0].toUpperCase() + sport.substring(1),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.group,
                  label: type[0].toUpperCase() + type.substring(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: '${endDate.difference(startDate).inDays} days',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.fitness_center,
                  label: '$minWeeklyActivities/week',
                ),
              ],
            ),
            if (milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoChip(
                icon: Icons.flag,
                label: '${milestones.length} milestones',
              ),
            ],
            if (wager != null && wager!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoChip(
                icon: Icons.local_offer,
                label: wager!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Friend selector (placeholder - needs implementation based on your user system)
class FriendSelector extends StatelessWidget {
  final List<String> selectedUserIds;
  final Function(List<String>) onSelectionChanged;

  const FriendSelector({
    Key? key,
    required this.selectedUserIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder - implement based on your user/friend system
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Friends to Invite',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder content
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Friend selector will be implemented here',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create challenge button
class CreateChallengeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateChallengeButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Create Challenge 🎯',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Add milestone dialog
class AddMilestoneDialog extends StatefulWidget {
  final Function(ChallengeMilestone) onAdd;

  const AddMilestoneDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddMilestoneDialog> createState() => _AddMilestoneDialogState();
}

class _AddMilestoneDialogState extends State<AddMilestoneDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  String _type = 'points';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Milestone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., First Week Complete',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe the milestone',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              items: const [
                DropdownMenuItem(value: 'points', child: Text('Points')),
                DropdownMenuItem(value: 'streak', child: Text('Streak')),
                DropdownMenuItem(value: 'activities', child: Text('Activities')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Value',
                hintText: _type == 'custom' ? '1' : 'e.g., 100',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canAdd() ? _add : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  bool _canAdd() {
    return _nameController.text.isNotEmpty && 
           _targetController.text.isNotEmpty;
  }

  void _add() {
    final milestone = ChallengeMilestone(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      type: _type,
      target: int.tryParse(_targetController.text) ?? 0,
    );
    
    widget.onAdd(milestone);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}