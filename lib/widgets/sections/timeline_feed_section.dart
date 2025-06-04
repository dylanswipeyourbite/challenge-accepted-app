// lib/widgets/sections/timeline_feed_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:challengeaccepted/models/media.dart';
import 'package:challengeaccepted/models/comment.dart';

class TimelineFeedSection extends StatelessWidget {
  const TimelineFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserActivityProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeader(provider.isLoadingTimeline),
            const SizedBox(height: 8),
            _buildContent(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isRefreshing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Timeline",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (isRefreshing)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, UserActivityProvider provider) {
    // First load
    if (provider.isLoadingTimeline && provider.timelineMedia.isEmpty) {
      return const _TimelineSkeletonLoader();
    }

    // Error state
    if (provider.error != null && provider.timelineMedia.isEmpty) {
      return _ErrorState(
        error: provider.error!,
        onRetry: () => provider.fetchTimelineMedia(),
      );
    }

    // Empty state
    if (provider.timelineMedia.isEmpty) {
      return const _EmptyTimeline();
    }

    // Timeline list
    return _TimelineList(
      mediaList: provider.timelineMedia,
      onMediaInteraction: (String mediaId, {bool? hasCheered, List<Comment>? comments}) {
        provider.updateMediaInteraction(
          mediaId,
          hasCheered: hasCheered,
          comments: comments,
        );
      },
    );
  }
}

class _TimelineList extends StatelessWidget {
  final List<Media> mediaList;
  final Function(String mediaId, {bool? hasCheered, List<Comment>? comments}) onMediaInteraction;

  const _TimelineList({
    required this.mediaList,
    required this.onMediaInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final media = mediaList[index];
        return _buildPostCard(media);
      },
    );
  }

  Widget _buildPostCard(Media media) {
    return PostCard(
      mediaId: media.id,
      imageUrl: media.url,
      displayName: media.user.displayName,
      avatarUrl: media.user.avatarUrl ?? '',
      cheers: media.cheers,
      comments: media.comments.map((c) => c.toJson()).toList(), // Convert to List<dynamic> for now
      hasCheered: media.hasCheered,
      onRefetch: () {
        // Update is handled by provider
        onMediaInteraction(media.id);
      },
      caption: media.caption,
      uploadedAt: media.uploadedAt,
      dailyLog: media.dailyLog,
    );
  }
}

class _TimelineSkeletonLoader extends StatelessWidget {
  const _TimelineSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) => _SkeletonCard()),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start logging activities to see posts here!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}