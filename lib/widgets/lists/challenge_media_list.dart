// lib/widgets/lists/challenge_media_list.dart
import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:challengeaccepted/models/media.dart';

class ChallengeMediaList extends StatelessWidget {
  final List<Media> mediaList;
  final VoidCallback? onRefetch;

  const ChallengeMediaList({
    super.key,
    required this.mediaList,
    this.onRefetch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: mediaList.map((media) {
        return PostCard(
          media: media,
          dailyLog: media.dailyLog,
        );
      }).toList(),
    );
  }
}