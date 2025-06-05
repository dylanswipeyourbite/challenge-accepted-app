// lib/widgets/provider_aware/challenge_media_feed.dart
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/models/media.dart';

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

        if (result.hasException) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading media: ${result.exception}',
                  style: TextStyle(color: Colors.red.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final mediaData = result.data?['mediaByChallenge'] ?? [];
        
        if (mediaData.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined, 
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
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share!',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
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
              if (index >= mediaData.length) return null;
              
              try {
                final media = Media.fromJson(mediaData[index]);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PostCard(
                    media: media,
                    dailyLog: media.dailyLog,
                  ),
                );
              } catch (e) {
                // Handle parsing errors gracefully
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Error loading post: $e',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                );
              }
            },
            childCount: mediaData.length > 5 ? 5 : mediaData.length,
          ),
        );
      },
    );
  }
}