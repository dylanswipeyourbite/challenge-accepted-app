// lib/widgets/forms/daily_log_form.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/widgets/forms/activity_type_selector.dart';
import 'package:challengeaccepted/widgets/forms/media_upload_section.dart';

class DailyLogForm extends StatefulWidget {
  final String challengeId;
  final bool canTakeRestDay;
  final VoidCallback onComplete;

  const DailyLogForm({
    super.key,
    required this.challengeId,
    required this.canTakeRestDay,
    required this.onComplete,
  });

  @override
  State<DailyLogForm> createState() => _DailyLogFormState();
}

class _DailyLogFormState extends State<DailyLogForm> {
  String _selectedLogType = 'activity';
  String _activityType = 'running';
  String? _mediaUrl;
  String? _mediaType;
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;

  static const String logActivityWithMedia = """
    mutation LogActivityWithMedia(\$logInput: LogActivityInput!, \$mediaInput: AddMediaInput) {
      logDailyActivity(input: \$logInput) {
        id
        type
        points
        participant {
          dailyStreak
          totalPoints
        }
      }
      addMedia(input: \$mediaInput) @skip(if: \$skipMedia) {
        id
        url
        caption
      }
    }
  """;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _onLogTypeChanged(String type) {
    setState(() {
      _selectedLogType = type;
    });
  }

  void _onActivityTypeChanged(String type) {
    setState(() {
      _activityType = type;
    });
  }

  void _onMediaUploaded(String url, String type) {
    setState(() {
      _mediaUrl = url;
      _mediaType = type;
    });
  }

  void _onUploadingChanged(bool uploading) {
    setState(() {
      _isUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(logActivityWithMedia),
        onCompleted: (data) {
          final points = data?['logDailyActivity']?['points'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Logged! +$points points'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onComplete();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${error?.graphqlErrors.first.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
      builder: (runMutation, result) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What did you do today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ActivityTypeSelector(
              selectedLogType: _selectedLogType,
              canTakeRestDay: widget.canTakeRestDay,
              onLogTypeChanged: _onLogTypeChanged,
              selectedActivityType: _activityType,
              onActivityTypeChanged: _onActivityTypeChanged,
            ),
            const SizedBox(height: 24),
            MediaUploadSection(
              challengeId: widget.challengeId,
              logType: _selectedLogType,
              captionController: _captionController,
              onMediaUploaded: _onMediaUploaded,
              onUploadingChanged: _onUploadingChanged,
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(runMutation, result!),
            const SizedBox(height: 16),
            _buildInfoMessage(),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(RunMutation runMutation, QueryResult result) {
    final isLoading = result.isLoading || _isUploading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: _selectedLogType == 'activity' ? Colors.green : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : () => _submitLog(runMutation),
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
                _selectedLogType == 'activity'
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

  Widget _buildInfoMessage() {
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

  void _submitLog(RunMutation runMutation) {
    final logInput = {
      'challengeId': widget.challengeId,
      'type': _selectedLogType,
      'activityType': _selectedLogType == 'activity' ? _activityType : null,
      'notes': _captionController.text.isNotEmpty ? _captionController.text : null,
      'date': DateTime.now().toIso8601String(),
    };

    final variables = {
      'logInput': logInput,
      'skipMedia': _mediaUrl == null,
    };

    if (_mediaUrl != null) {
      variables['mediaInput'] = {
        'challengeId': widget.challengeId,
        'url': _mediaUrl,
        'type': _mediaType,
        'caption': _captionController.text.isNotEmpty ? _captionController.text : null,
      };
    }

    runMutation(variables);
  }
}