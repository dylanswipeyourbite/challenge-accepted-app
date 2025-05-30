import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

class DailyActivitySelectorPage extends StatefulWidget {
  const DailyActivitySelectorPage({super.key});

  @override
  State<DailyActivitySelectorPage> createState() => _DailyActivitySelectorPageState();
}

class _DailyActivitySelectorPageState extends State<DailyActivitySelectorPage> {
  final Set<String> selectedChallengeIds = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Challenges'),
        actions: [
          TextButton(
            onPressed: selectedChallengeIds.isEmpty ? null : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiChallengeDailyLogPage(
                    challengeIds: selectedChallengeIds.toList(),
                  ),
                ),
              );
            },
            child: Text(
              'Next (${selectedChallengeIds.length})',
              style: TextStyle(
                color: selectedChallengeIds.isEmpty ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(ChallengesQueries.getActiveChallenges),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return const Center(
              child: Text('Not authenticated'),
            );
          }

          final challenges = result.data?['challenges'] as List<dynamic>? ?? [];
          
          // Filter to show only active challenges where user has accepted
          final activeChallenges = challenges.where((challenge) {
            if (challenge['status'] == 'expired') return false;
            
            final participants = challenge['participants'] as List<dynamic>?;
            if (participants == null) return false;
            
            // Find if the current user is an accepted participant
            try {
              participants.firstWhere(
                (p) => p['user'] != null && p['status'] == 'accepted',
              );
              return true;
            } catch (_) {
              return false;
            }
          }).toList();

          if (activeChallenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No active challenges',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join a challenge first to log activities',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select the challenges you want to log activity for',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = activeChallenges[index];
                    final challengeId = challenge['id'] as String;
                    final isSelected = selectedChallengeIds.contains(challengeId);
                    
                    // Get participant info for this challenge
                    final participants = challenge['participants'] as List<dynamic>;
                    
                    // Use try-catch instead of orElse for finding participant
                    Map<String, dynamic>? userParticipant;
                    try {
                      userParticipant = participants.firstWhere(
                        (p) => p['user'] != null && p['status'] == 'accepted',
                      ) as Map<String, dynamic>;
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                    
                    final streak = userParticipant['dailyStreak'] as int? ?? 0;
                    final totalPoints = userParticipant['totalPoints'] as int? ?? 0;
                    
                    return Card(
                      elevation: isSelected ? 4 : 1,
                      color: isSelected ? Colors.green.shade50 : null,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedChallengeIds.remove(challengeId);
                            } else {
                              selectedChallengeIds.add(challengeId);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.grey,
                                    width: 2,
                                  ),
                                  color: isSelected ? Colors.green : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      challenge['title'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 16,
                                          color: Colors.orange.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$streak day streak',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$totalPoints points',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                challenge['type'] == 'competitive'
                                    ? Icons.emoji_events
                                    : Icons.group,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Multi-challenge daily log page
class MultiChallengeDailyLogPage extends StatefulWidget {
  final List<String> challengeIds;

  const MultiChallengeDailyLogPage({
    super.key,
    required this.challengeIds,
  });

  @override
  State<MultiChallengeDailyLogPage> createState() => _MultiChallengeDailyLogPageState();
}

class _MultiChallengeDailyLogPageState extends State<MultiChallengeDailyLogPage> {
  int currentChallengeIndex = 0;
  final Map<String, bool> completedChallenges = {};

  void _onChallengeLogged(String challengeId) {
    setState(() {
      completedChallenges[challengeId] = true;
      
      if (currentChallengeIndex < widget.challengeIds.length - 1) {
        currentChallengeIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('All Done! 🎉'),
        content: Text(
          'You\'ve logged activity for ${widget.challengeIds.length} challenge${widget.challengeIds.length > 1 ? 's' : ''}!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.challengeIds.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No challenges selected')),
      );
    }

    final currentChallengeId = widget.challengeIds[currentChallengeIndex];

    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getChallenge),
        variables: {'id': currentChallengeId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (result.hasException) {
          return Scaffold(
            body: Center(child: Text('Error: ${result.exception.toString()}')),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Not authenticated')),
          );
        }

        final challengeData = result.data?['challenge'] as Map<String, dynamic>?;
        if (challengeData == null) {
          return const Scaffold(
            body: Center(child: Text('Challenge not found')),
          );
        }

        final participants = challengeData['participants'] as List<dynamic>;
        
        // Find user participant with proper null safety
        Map<String, dynamic>? userParticipant;
        try {
          userParticipant = participants.firstWhere(
            (p) => p['user'] != null && p['status'] == 'accepted',
          ) as Map<String, dynamic>;
        } catch (_) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You are not an accepted participant in this challenge'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return IntegratedDailyLogPage(
          challengeId: currentChallengeId,
          challengeTitle: challengeData['title'] as String,
          allowedRestDays: userParticipant['restDays'] as int? ?? 1,
          usedRestDays: userParticipant['weeklyRestDaysUsed'] as int? ?? 0,
          currentStreak: userParticipant['dailyStreak'] as int? ?? 0,
          isMultiChallenge: widget.challengeIds.length > 1,
          challengeProgress: '${currentChallengeIndex + 1} of ${widget.challengeIds.length}',
          onComplete: () => _onChallengeLogged(currentChallengeId),
        );
      },
    );
  }
}

// IntegratedDailyLogPage implementation
class IntegratedDailyLogPage extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final int allowedRestDays;
  final int usedRestDays;
  final int currentStreak;
  final bool isMultiChallenge;
  final String? challengeProgress;
  final VoidCallback? onComplete;

  const IntegratedDailyLogPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.allowedRestDays,
    required this.usedRestDays,
    required this.currentStreak,
    this.isMultiChallenge = false,
    this.challengeProgress,
    this.onComplete,
  });

  @override
  State<IntegratedDailyLogPage> createState() => _IntegratedDailyLogPageState();
}

class _IntegratedDailyLogPageState extends State<IntegratedDailyLogPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();
  
  String _selectedLogType = 'activity'; // 'activity' or 'rest'
  String _activityType = 'running';
  XFile? _selectedMedia;
  bool _isUploading = false;

  // Updated mutation that combines logging + media upload
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

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              final file = await _picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              final file = await _picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: () async {
              final file = await _picker.pickVideo(source: ImageSource.camera);
              Navigator.pop(context, file);
            },
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = pickedFile;
      });
    }
  }

  Future<String?> _uploadMedia() async {
    if (_selectedMedia == null) return null;

    setState(() => _isUploading = true);

    try {
      final fileBytes = await _selectedMedia!.readAsBytes();
      final fileName = _selectedMedia!.name;
      final fileExtension = fileName.split('.').last.toLowerCase();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('challenges/${widget.challengeId}/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: ['mp4', 'mov'].contains(fileExtension) 
              ? 'video/mp4' 
              : 'image/jpeg',
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTakeRestDay = widget.usedRestDays < widget.allowedRestDays;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Today - ${widget.challengeTitle}'),
            if (widget.isMultiChallenge && widget.challengeProgress != null)
              Text(
                'Challenge ${widget.challengeProgress}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: Mutation(
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
            
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else {
              Navigator.of(context).pop();
            }
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current streak display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.red.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.currentStreak} 🔥',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Rest day info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bed, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Rest days: ${widget.usedRestDays}/${widget.allowedRestDays} used this week',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Log type selection
                const Text(
                  'What did you do today?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Activity or Rest selection
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedLogType = 'activity'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedLogType == 'activity' 
                                ? Colors.green.shade100 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedLogType == 'activity' 
                                  ? Colors.green 
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_run,
                                size: 40,
                                color: _selectedLogType == 'activity' 
                                    ? Colors.green 
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'I was active',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedLogType == 'activity' 
                                      ? Colors.green.shade700 
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const Text(
                                '+10 points',
                                style: TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: canTakeRestDay 
                            ? () => setState(() => _selectedLogType = 'rest')
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !canTakeRestDay 
                                ? Colors.grey.shade200
                                : _selectedLogType == 'rest' 
                                    ? Colors.blue.shade100 
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !canTakeRestDay 
                                  ? Colors.grey.shade300
                                  : _selectedLogType == 'rest' 
                                      ? Colors.blue 
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bed,
                                size: 40,
                                color: !canTakeRestDay 
                                    ? Colors.grey.shade400
                                    : _selectedLogType == 'rest' 
                                        ? Colors.blue 
                                        : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rest day',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !canTakeRestDay 
                                      ? Colors.grey.shade400
                                      : _selectedLogType == 'rest' 
                                          ? Colors.blue.shade700 
                                          : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                canTakeRestDay ? '+5 points' : 'No more this week',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: canTakeRestDay ? Colors.blue : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Activity type selection (if activity selected)
                if (_selectedLogType == 'activity') ...[
                  const Text(
                    'Activity Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _activityType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['running', 'cycling', 'workout', 'other'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _activityType = value!),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // 📸 INTEGRATED MEDIA UPLOAD SECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedLogType == 'activity' 
                                ? 'Share your workout!' 
                                : 'Share your rest day vibes!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Selected media preview
                      if (_selectedMedia != null) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<Uint8List>(
                                  future: _selectedMedia!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Icon(Icons.error, color: Colors.red),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedMedia = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Media selection button
                      if (_selectedMedia == null)
                        OutlinedButton.icon(
                          onPressed: _pickMedia,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Photo/Video (Optional)'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Caption field
                      TextField(
                        controller: captionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: _selectedLogType == 'activity' 
                              ? 'How did your workout go? Share your thoughts...'
                              : 'How are you spending your rest day?',
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _selectedLogType == 'activity' 
                          ? Colors.green 
                          : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (result?.isLoading == true || _isUploading) 
                        ? null 
                        : () async {
                            // Upload media first if selected
                            String? mediaUrl;
                            if (_selectedMedia != null) {
                              mediaUrl = await _uploadMedia();
                              if (mediaUrl == null) return; // Upload failed
                            }

                            // Prepare variables
                            final logInput = {
                              'challengeId': widget.challengeId,
                              'type': _selectedLogType,
                              'activityType': _selectedLogType == 'activity' ? _activityType : null,
                              'notes': captionController.text.isNotEmpty ? captionController.text : null,
                              'date': DateTime.now().toIso8601String(),
                            };

                            Map<String, dynamic> variables = {
                              'logInput': logInput,
                              'skipMedia': mediaUrl == null,
                            };

                            if (mediaUrl != null) {
                              final fileExtension = _selectedMedia!.name.split('.').last.toLowerCase();
                              variables['mediaInput'] = {
                                'challengeId': widget.challengeId,
                                'url': mediaUrl,
                                'type': ['mp4', 'mov'].contains(fileExtension) ? 'video' : 'photo',
                                'caption': captionController.text.isNotEmpty ? captionController.text : null,
                              };
                            }

                            runMutation(variables);
                          },
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Uploading...', style: TextStyle(color: Colors.white)),
                            ],
                          )
                        : result?.isLoading == true
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
                ),
                
                const SizedBox(height: 16),
                
                // Info text
                Container(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}