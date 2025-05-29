import 'package:challengeaccepted/widgets/post_interaction_bar.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String mediaId;
  final String imageUrl;
  final String displayName;
  final String avatarUrl;
  final List cheers;
  final bool hasCheered;
  final DateTime? uploadedAt;
  final List comments;
  final VoidCallback? onRefetch;
  final String? caption; 

  const PostCard({
    super.key,
    required this.mediaId,
    required this.imageUrl,
    required this.displayName,
    required this.avatarUrl,
    required this.cheers,
    required this.hasCheered,
    required this.comments,
    this.onRefetch,
    this.uploadedAt,
    this.caption, 
  });

  @override
  Widget build(BuildContext context) {
    final hasCaption = caption != null && caption!.trim().isNotEmpty;
    print('hasCaption:');
    print(hasCaption);
    print('caption:');
    print(caption);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 Avatar and name
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 📝 Caption (if available)
        if (hasCaption)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              caption!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),

        // 📸 Media
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => const Text('⚠️ Failed to load image'),
          ),
        ),

        // 🚀 Interaction bar
        PostInteractionBar(
          mediaId: mediaId,
          cheers: cheers,
          comments: comments,
          hasCheered: hasCheered,
          onRefetch: onRefetch,
        )
      ],
    );
  }
}
