import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:challengeaccepted/utils/graphql_helpers.dart';

class TimelineFeedSection extends StatelessWidget {
  const TimelineFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getTimelineMedia),
        fetchPolicy: GraphQLHelpers.getFetchPolicyFor(QueryType.timeline),
        // This will show cached data immediately, then fetch fresh data
      ),
      builder: (result, {refetch, fetchMore}) {
        // Handle different states
        final isFirstLoad = result.isLoading && result.data == null;
        final isRefreshing = result.isLoading && result.data != null;
        
        if (isFirstLoad) {
          return const _TimelineSkeletonLoader();
        }

        if (result.hasException && result.data == null) {
          return _ErrorState(
            error: result.exception.toString(),
            onRetry: refetch,
          );
        }

        final mediaList = result.data?['timelineMedia'] as List<dynamic>? ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
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
            ),
            const SizedBox(height: 8),
            if (mediaList.isEmpty)
              const _EmptyTimeline()
            else
              _TimelineList(
                mediaList: mediaList,
                onRefetch: refetch,
              ),
          ],
        );
      },
    );
  }
}

class _TimelineSkeletonLoader extends StatelessWidget {
  const _TimelineSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) => _buildSkeletonCard()),
    );
  }

  Widget _buildSkeletonCard() {
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