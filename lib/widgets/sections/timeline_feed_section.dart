// lib/widgets/sections/timeline_feed_section.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';

class TimelineFeedSection extends StatelessWidget {
  const TimelineFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getTimelineMedia),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Text('Error: ${result.exception.toString()}');
        }

        final mediaList = result.data?['timelineMedia'] as List<dynamic>? ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Timeline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (mediaList.isEmpty)
              const _EmptyTimeline()
            else
              _TimelineList(mediaList: mediaList, onRefetch: refetch),
          ],
        );
      },
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
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  final List<dynamic> mediaList;
  final VoidCallback? onRefetch;

  const _TimelineList({
    required this.mediaList,
    this.onRefetch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final media = mediaList[index] as Map<String, dynamic>;
        return _buildPostCard(media);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> media) {
    final user = media['user'] as Map<String, dynamic>?;
    final cheers = media['cheers'] as List<dynamic>? ?? [];
    final comments = media['comments'] as List<dynamic>? ?? [];
    final dailyLog = media['dailyLog'] as Map<String, dynamic>?;
    
    return PostCard(
      mediaId: media['id'] as String,
      imageUrl: media['url'] as String,
      displayName: user?['displayName'] as String? ?? 'Unknown',
      avatarUrl: user?['avatarUrl'] as String? ?? '',
      cheers: cheers,
      comments: comments,
      hasCheered: media['hasCheered'] as bool? ?? false,
      onRefetch: onRefetch,
      caption: media['caption'] as String?,
      uploadedAt: _parseDateTime(media['uploadedAt']),
      dailyLog: dailyLog,
    );
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}