import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class IntegratedDailyLogPage extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final int allowedRestDays;
  final int usedRestDays;
  final int currentStreak;

  const IntegratedDailyLogPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.allowedRestDays,
    required this.usedRestDays,
    required this.currentStreak,
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
        title: Text('Log Today - ${widget.challengeTitle}'),
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
            Navigator.of(context).pop();
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
                      ],                      // Media selection button
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