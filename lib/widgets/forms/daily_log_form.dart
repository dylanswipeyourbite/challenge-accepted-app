import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/utils/graphql_helpers.dart';
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

  // Mutation for activity without media
  static const String logActivityOnly = """
    mutation LogActivityOnly(\$logInput: LogActivityInput!) {
      logDailyActivity(input: \$logInput) {
        id
        type
        points
        participant {
          dailyStreak
          totalPoints
        }
      }
    }
  """;

  // Mutation for activity with media
  static const String logActivityWithMedia = """
    mutation LogActivityWithMedia(
      \$logInput: LogActivityInput!, 
      \$mediaInput: AddMediaInput!
    ) {
      logDailyActivity(input: \$logInput) {
        id
        type
        points
        participant {
          dailyStreak
          totalPoints
        }
      }
      addMedia(input: \$mediaInput) {
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
    final hasMedia = _mediaUrl != null;
    
    return Mutation(
      options: MutationOptions(
        document: gql(hasMedia ? logActivityWithMedia : logActivityOnly),
        onCompleted: (data) async {
          if (data == null) return;
          
          final points = data['logDailyActivity']?['points'] ?? 0;
          final newStreak = data['logDailyActivity']?['participant']?['dailyStreak'] ?? 0;
          
          // Haptic feedback
          HapticFeedback.mediumImpact();
          
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Logged! +$points points'),
                    if (newStreak > 0) ...[
                      const SizedBox(width: 8),
                      Text('🔥 $newStreak day streak!'),
                    ],
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          
          // Refresh affected queries
          final client = GraphQLProvider.of(context).value;
          await GraphQLHelpers.refetchAfterPost(client, widget.challengeId);
          
          // Small delay for animation
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (context.mounted) {
            widget.onComplete();
          }
        },
        onError: (error) {
          _handleError(error);
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
            
            // Activity type selector
            ActivityTypeSelector(
              selectedLogType: _selectedLogType,
              canTakeRestDay: widget.canTakeRestDay,
              onLogTypeChanged: _onLogTypeChanged,
              selectedActivityType: _activityType,
              onActivityTypeChanged: _onActivityTypeChanged,
            ),
            
            const SizedBox(height: 24),
            
            // Media upload section
            MediaUploadSection(
              challengeId: widget.challengeId,
              logType: _selectedLogType,
              captionController: _captionController,
              onMediaUploaded: _onMediaUploaded,
              onUploadingChanged: _onUploadingChanged,
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            _buildSubmitButton(runMutation, result!),
            
            const SizedBox(height: 16),
            
            // Info message
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

    final variables = <String, dynamic>{
      'logInput': logInput,
    };

    // Add media input only if we have media
    if (_mediaUrl != null) {
      variables['mediaInput'] = {
        'challengeId': widget.challengeId,
        'url': _mediaUrl,
        'type': _mediaType ?? 'photo',
        'caption': _captionController.text.isNotEmpty ? _captionController.text : null,
      };
    }

    print('🚀 Submitting log with variables:');
    print('  - Challenge ID: ${widget.challengeId}');
    print('  - Log type: $_selectedLogType');
    print('  - Has media: ${_mediaUrl != null}');

    runMutation(variables);
  }

  void _handleError(OperationException? error) {
    print('[❌] GraphQL Error: $error');
    
    String errorMessage = 'Error logging activity';
    
    if (error?.graphqlErrors.isNotEmpty ?? false) {
      errorMessage = error!.graphqlErrors.first.message;
    } else if (error?.linkException != null) {
      errorMessage = 'Network error. Please check your connection.';
    }
    
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}