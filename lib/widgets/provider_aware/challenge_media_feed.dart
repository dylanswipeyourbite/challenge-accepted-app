import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';

class ChallengeMediaFeed extends StatelessWidget {
  final String challengeId;

  const ChallengeMediaFeed({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getMediaByChallenge),
        variables: {'challengeId': challengeId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final mediaList = result.data?['mediaByChallenge'] as List? ?? [];
        
        if (mediaList.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, 
                      size: 48, 
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activity yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= mediaList.length) return null;
              
              final media = mediaList[index] as Map<String, dynamic>;
              return _buildPostCard(media, refetch);
            },
            childCount: mediaList.length > 5 ? 5 : mediaList.length,
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> media, VoidCallback? onRefetch) {
    final user = media['user'] as Map<String, dynamic>?;
    final cheers = media['cheers'] as List<dynamic>? ?? [];
    final comments = media['comments'] as List<dynamic>? ?? [];
    
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
    );
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}