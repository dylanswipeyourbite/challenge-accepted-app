// lib/widgets/lists/challenge_media_list.dart
import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:challengeaccepted/models/media.dart';

class ChallengeMediaList extends StatelessWidget {
  final List<dynamic> mediaList;
  final VoidCallback? onRefetch;

  const ChallengeMediaList({
    super.key,
    required this.mediaList,
    this.onRefetch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: mediaList.map((entry) {
        try {
          final mediaData = entry as Map<String, dynamic>;
          final media = Media.fromJson(mediaData);
          
          return PostCard(
            media: media,
            dailyLog: media.dailyLog,
          );
        } catch (e) {
          // Handle parsing errors gracefully
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading post: ${e.toString()}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          );
        }
      }).toList(),
    );
  }
}