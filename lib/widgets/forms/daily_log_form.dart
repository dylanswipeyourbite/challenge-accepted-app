import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:challengeaccepted/widgets/media/reusable_media_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:challengeaccepted/services/activity_logging_service.dart';
import 'package:challengeaccepted/widgets/dialogs/activity_success_dialog.dart';

class RefactoredDailyLogForm extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final bool canTakeRestDay;
  final VoidCallback onComplete;

  const RefactoredDailyLogForm({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.canTakeRestDay,
    required this.onComplete,
  });

  @override
  State<RefactoredDailyLogForm> createState() => _RefactoredDailyLogFormState();
}

class _RefactoredDailyLogFormState extends State<RefactoredDailyLogForm> {
  LogType _selectedLogType = LogType.activity;
  ActivityType _activityType = ActivityType.running;
  ReusableMediaUploadResult? _mediaResult;
  bool _isSubmitting = false;

  late final ActivityLoggingService _loggingService;

  @override
  void initState() {
    super.initState();
    _loggingService = ActivityLoggingService.of(context);
  }

  Future<void> _submitLog() async {
    setState(() => _isSubmitting = true);

    final result = await _loggingService.logActivity(
      challengeId: widget.challengeId,
      type: _selectedLogType,
      activityType: _activityType,
      mediaUrl: _mediaResult?.url,
      mediaType: _mediaResult?.type,
      caption: _mediaResult?.caption,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result.success) {
      HapticFeedback.mediumImpact();
      
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ActivitySuccessDialog(
          pointsEarned: result.pointsEarned,
          newStreak: result.newStreak,
          challengeTitle: widget.challengeTitle,
          onComplete: widget.onComplete,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(result.error ?? 'Failed to log activity')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What did you do today?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Activity type selector
        _ActivityTypeSelector(
          selectedLogType: _selectedLogType,
          canTakeRestDay: widget.canTakeRestDay,
          onLogTypeChanged: (type) => setState(() => _selectedLogType = type),
          selectedActivityType: _activityType,
          onActivityTypeChanged: (type) => setState(() => _activityType = type),
        ),
        
        const SizedBox(height: 24),
        
        // Media upload
        ReusableMediaUpload(
          challengeId: widget.challengeId,
          onMediaUploaded: (result) => setState(() => _mediaResult = result),
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $error')),
            );
          },
          hintText: _selectedLogType == LogType.activity
              ? 'How did your workout go? Share your thoughts...'
              : 'How are you spending your rest day?',
          primaryColor: _selectedLogType == LogType.activity 
              ? Colors.green 
              : Colors.blue,
        ),
        
        const SizedBox(height: 32),
        
        // Submit button
        _SubmitButton(
          isLoading: _isSubmitting,
          logType: _selectedLogType,
          onPressed: _submitLog,
        ),
        
        const SizedBox(height: 16),
        
        // Info message
        const _InfoMessage(),
      ],
    );
  }
}

class _ActivityTypeSelector extends StatelessWidget {
  final LogType selectedLogType;
  final bool canTakeRestDay;
  final ValueChanged<LogType> onLogTypeChanged;
  final ActivityType selectedActivityType;
  final ValueChanged<ActivityType> onActivityTypeChanged;

  const _ActivityTypeSelector({
    required this.selectedLogType,
    required this.canTakeRestDay,
    required this.onLogTypeChanged,
    required this.selectedActivityType,
    required this.onActivityTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _LogTypeCard(
                type: LogType.activity,
                isSelected: selectedLogType == LogType.activity,
                icon: Icons.directions_run,
                label: 'I was active',
                points: '+10 points',
                baseColor: Colors.green,
                onTap: () => onLogTypeChanged(LogType.activity),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LogTypeCard(
                type: LogType.rest,
                isSelected: selectedLogType == LogType.rest,
                icon: Icons.bed,
                label: 'Rest day',
                points: canTakeRestDay ? '+5 points' : 'No more this week',
                baseColor: Colors.blue,
                isEnabled: canTakeRestDay,
                onTap: canTakeRestDay 
                    ? () => onLogTypeChanged(LogType.rest) 
                    : null,
              ),
            ),
          ],
        ),
        if (selectedLogType == LogType.activity) ...[
          const SizedBox(height: 24),
          const Text(
            'Activity Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActivityTypeDropdown(
            value: selectedActivityType,
            onChanged: onActivityTypeChanged,
          ),
        ],
      ],
    );
  }
}

class _LogTypeCard extends StatelessWidget {
  final LogType type;
  final bool isSelected;
  final IconData icon;
  final String label;
  final String points;
  final MaterialColor baseColor;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _LogTypeCard({
    required this.type,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.points,
    required this.baseColor,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !isEnabled
              ? Colors.grey.shade200
              : isSelected
                  ? baseColor.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !isEnabled
                ? Colors.grey.shade300
                : isSelected
                    ? baseColor
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: !isEnabled
                  ? Colors.grey.shade400
                  : isSelected
                      ? baseColor
                      : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: !isEnabled
                    ? Colors.grey.shade400
                    : isSelected
                        ? baseColor.shade700
                        : Colors.grey.shade600,
              ),
            ),
            Text(
              points,
              style: TextStyle(
                fontSize: 12,
                color: !isEnabled
                    ? Colors.red
                    : type == LogType.activity
                        ? Colors.green
                        : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTypeDropdown extends StatelessWidget {
  final ActivityType value;
  final ValueChanged<ActivityType> onChanged;

  const _ActivityTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ActivityType>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: ActivityType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final LogType logType;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.logType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: logType == LogType.activity ? Colors.green : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                logType == LogType.activity
                    ? 'Log Activity (+10 points)'
                    : 'Log Rest Day (+5 points)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your post will appear in the challenge timeline and your friends\' feeds. Consistency is key! 🔥',
              style: TextStyle(color: Colors.amber.shade700),
            ),
          ),
        ],
      ),
    );
  }
}