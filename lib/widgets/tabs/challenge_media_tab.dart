// lib/widgets/tabs/challenge_media_tab.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/lists/challenge_media_list.dart';
import 'package:challengeaccepted/widgets/buttons/upload_media_button.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';
import 'package:challengeaccepted/widgets/common/empty_state.dart';

class ChallengeMediaTab extends StatelessWidget {
  final String challengeId;
  final String challengeTitle;

  const ChallengeMediaTab({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
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
          return const LoadingIndicator();
        }

        if (result.hasException) {
          return ErrorMessage(
            message: 'Failed to load media',
            error: result.exception.toString(),
            onRetry: refetch,
          );
        }

        final mediaList = result.data?['mediaByChallenge'] as List<dynamic>? ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: RefreshIndicator(
            onRefresh: () async => await refetch?.call(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (mediaList.isEmpty)
                    const EmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'No media yet',
                      message: 'Be the first to share a photo or video!',
                    )
                  else
                    ChallengeMediaList(
                      mediaList: mediaList,
                      onRefetch: refetch,
                    ),
                  const SizedBox(height: 20),
                  UploadMediaButton(
                    challengeId: challengeId,
                    challengeTitle: challengeTitle,
                    onUploadComplete: refetch,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}