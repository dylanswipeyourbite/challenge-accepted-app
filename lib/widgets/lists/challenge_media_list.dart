// lib/widgets/lists/challenge_media_list.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/post_card.dart';

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
        final media = entry as Map<String, dynamic>;
        final user = media['user'] as Map<String, dynamic>?;
        final cheers = media['cheers'] as List<dynamic>? ?? [];
        final comments = media['comments'] as List<dynamic>? ?? [];

        return PostCard(
          mediaId: media['id'] as String,
          imageUrl: media['url'] as String,
          displayName: user?['displayName'] as String? ?? 'Unknown',
          avatarUrl: user?['avatarUrl'] as String? ?? '',
          hasCheered: media['hasCheered'] as bool? ?? false,
          cheers: cheers,
          uploadedAt: _parseDateTime(media['uploadedAt']),
          comments: comments,
          onRefetch: onRefetch,
          caption: media['caption'] as String?,
        );
      }).toList(),
    );
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}