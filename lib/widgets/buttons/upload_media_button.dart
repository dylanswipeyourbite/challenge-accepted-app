// lib/widgets/buttons/upload_media_button.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:challengeaccepted/graphql/mutations/media_mutations.dart';
import 'package:challengeaccepted/services/media_upload_service.dart';
import 'package:challengeaccepted/widgets/dialogs/caption_dialog.dart';

class UploadMediaButton extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final VoidCallback? onUploadComplete;

  const UploadMediaButton({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    this.onUploadComplete,
  });

  @override
  State<UploadMediaButton> createState() => _UploadMediaButtonState();
}

class _UploadMediaButtonState extends State<UploadMediaButton> {
  final ImagePicker _picker = ImagePicker();
  final MediaUploadService _uploadService = MediaUploadService();
  bool _isUploading = false;

  Future<void> _pickAndUploadMedia(RunMutation runMutation) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Get caption from user
    final caption = await showDialog<String>(
      context: context,
      builder: (context) => CaptionDialog(
        challengeTitle: widget.challengeTitle,
      ),
    );

    if (caption == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final result = await _uploadService.uploadMedia(
        file: pickedFile,
        challengeId: widget.challengeId,
      );

      if (result != null && mounted) {
        runMutation({
          "input": {
            "challengeId": widget.challengeId,
            "url": result.url,
            "type": result.type,
            "caption": caption,
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(MediaMutations.addMediaMutation),
        onCompleted: (_) {
          widget.onUploadComplete?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Upload failed: ${error?.graphqlErrors.first.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
      builder: (runMutation, result) {
        final isLoading = _isUploading || (result?.isLoading ?? false);

        return ElevatedButton.icon(
          onPressed: isLoading ? null : () => _pickAndUploadMedia(runMutation),
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_a_photo),
          label: Text(isLoading ? 'Uploading...' : 'Upload Photo/Video'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
      },
    );
  }
}