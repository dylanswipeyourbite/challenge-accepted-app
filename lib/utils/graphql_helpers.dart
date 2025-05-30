import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/queries/user_queries.dart';

class GraphQLHelpers {
  /// Refetch queries after posting activity/media
  static Future<void> refetchAfterPost(
    GraphQLClient client,
    String challengeId,
  ) async {
    try {
      await Future.wait([
        // Refresh timeline
        client.query(QueryOptions(
          document: gql(MediaQueries.getTimelineMedia),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        // Refresh specific challenge
        client.query(QueryOptions(
          document: gql(ChallengesQueries.getChallenge),
          variables: {'id': challengeId},
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        // Refresh user stats
        client.query(QueryOptions(
          document: gql(UserQueries.getUserStats),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        // Refresh active challenges (for the dashboard)
        client.query(QueryOptions(
          document: gql(ChallengesQueries.getActiveChallenges),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
      ]);
    } catch (e) {
      print('Error refreshing queries: $e');
    }
  }
  
  /// Refetch queries after accepting/declining challenge
  static Future<void> refetchAfterChallengeUpdate(GraphQLClient client) async {
    try {
      await Future.wait([
        client.query(QueryOptions(
          document: gql(ChallengesQueries.getActiveChallenges),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        client.query(QueryOptions(
          document: gql(ChallengesQueries.pendingChallenges),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        client.query(QueryOptions(
          document: gql(UserQueries.getUserStats),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
      ]);
    } catch (e) {
      print('Error refreshing challenge queries: $e');
    }
  }
  
  /// Get appropriate fetch policy based on data type
  static FetchPolicy getFetchPolicyFor(QueryType type) {
    switch (type) {
      case QueryType.timeline:
      case QueryType.activeStats:
        // Always fetch fresh data but show cached first
        return FetchPolicy.cacheAndNetwork;
      case QueryType.challengeDetails:
      case QueryType.userProfile:
        // Use cache first for stable data
        return FetchPolicy.cacheFirst;
      case QueryType.realtime:
        // Always fetch from network
        return FetchPolicy.networkOnly;
    }
  }
}

enum QueryType {
  timeline,
  activeStats,
  challengeDetails,
  userProfile,
  realtime,
}