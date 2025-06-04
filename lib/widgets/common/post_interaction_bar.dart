// lib/widgets/common/provider_aware_post_interaction_bar.dart
import 'package:challengeaccepted/widgets/buttons/cheer_button.dart';
import 'package:challengeaccepted/widgets/buttons/comment_button.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/media.dart';


class PostInteractionBar extends StatelessWidget {
  final Media media;

  const PostInteractionBar({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CheerButton(media: media),
        CommentButton(media: media),
      ],
    );
  }
}