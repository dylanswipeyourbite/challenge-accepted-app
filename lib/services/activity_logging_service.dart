// lib/services/activity_logging_service.dart
import 'package:challengeaccepted/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:challengeaccepted/models/media.dart';
import 'package:provider/provider.dart';

class ActivityLogResult {
  final bool success;
  final int pointsEarned;
  final int newStreak;
  final String? error;

  ActivityLogResult({
    required this.success,
    this.pointsEarned = 0,
    this.newStreak = 0,
    this.error,
  });
}

class ActivityLoggingService {
  static const String _logActivityOnly = """
    mutation LogActivityOnly(\$logInput: LogActivityInput!) {
      logDailyActivity(input: \$logInput) {
        id
        type
        points
        participant {
          dailyStreak
          totalPoints
        }
      }
    }
  """;

  static const String _logActivityWithMedia = """
    mutation LogActivityWithMedia(
      \$logInput: LogActivityInput!, 
      \$mediaInput: AddMediaInput!
    ) {
      logDailyActivity(input: \$logInput) {
        id
        type
        points
        participant {
          dailyStreak
          totalPoints
        }
      }
      addMedia(input: \$mediaInput) {
        id
        url
        caption
        type
        uploadedAt
        user {
          id
          displayName
          avatarUrl
        }
        cheers
        comments {
          id
          text
          author {
            id
            displayName
            avatarUrl
          }
          createdAt
        }
        hasCheered
      }
    }
  """;

  final GraphQLClient client;
  final ChallengeProvider challengeProvider;
  final UserActivityProvider userActivityProvider;

  ActivityLoggingService({
    required this.client,
    required this.challengeProvider,
    required this.userActivityProvider,
  });

  factory ActivityLoggingService.of(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    return ActivityLoggingService(
      client: client,
      challengeProvider: challengeProvider,
      userActivityProvider: userActivityProvider,
    );
  }

  Future<ActivityLogResult> logActivity({
    required String challengeId,
    required LogType type,
    ActivityType? activityType,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    String? notes,
  }) async {
    try {
      // Check if user can take rest day
      if (type == LogType.rest) {
        final userParticipant = challengeProvider.getCurrentUserParticipant(challengeId);
        if (userParticipant == null) {
          return ActivityLogResult(
            success: false,
            error: 'User not found in challenge',
          );
        }

        if (!userParticipant.canTakeRestDay) {
          return ActivityLogResult(
            success: false,
            error: 'No rest days remaining this week',
          );
        }
      }

      // Prepare log input
      final logInput = {
        'challengeId': challengeId,
        'type': type.value,
        'activityType': type == LogType.activity ? activityType?.value : null,
        'notes': notes ?? caption,
        'date': DateTime.now().toIso8601String(),
      };

      final variables = <String, dynamic>{
        'logInput': logInput,
      };

      // Add media input if provided
      final hasMedia = mediaUrl != null;
      if (hasMedia) {
        variables['mediaInput'] = {
          'challengeId': challengeId,
          'url': mediaUrl,
          'type': mediaType ?? 'photo',
          'caption': caption,
        };
      }

      // Execute mutation
      final result = await client.mutate(
        MutationOptions(
          document: gql(hasMedia ? _logActivityWithMedia : _logActivityOnly),
          variables: variables,
        ),
      );

      if (result.hasException) {
        return ActivityLogResult(
          success: false,
          error: result.exception?.graphqlErrors.firstOrNull?.message ?? 
                 'Failed to log activity',
        );
      }

      // Extract results
      final logData = result.data?['logDailyActivity'];
      if (logData == null) {
        return ActivityLogResult(
          success: false,
          error: 'Invalid response from server',
        );
      }

      final points = logData['points'] as int? ?? 0;
      final newStreak = logData['participant']?['dailyStreak'] as int? ?? 0;

      // Update providers
      challengeProvider.updateLogStatus(challengeId, true);
      userActivityProvider.updateAfterActivityLog(
        pointsEarned: points,
        newStreak: newStreak,
        challengeId: challengeId,
      );

      // If media was added, add to timeline
      if (hasMedia && result.data?['addMedia'] != null) {
        final mediaData = result.data!['addMedia'] as Map<String, dynamic>;
        final media = Media.fromJson(mediaData);
        userActivityProvider.addMediaToTimeline(media);
      }

      return ActivityLogResult(
        success: true,
        pointsEarned: points,
        newStreak: newStreak,
      );
    } catch (e) {
      return ActivityLogResult(
        success: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<List<ActivityLogResult>> logMultipleChallenges({
    required List<String> challengeIds,
    required LogType type,
    ActivityType? activityType,
    String? notes,
  }) async {
    final results = <ActivityLogResult>[];
    
    for (final challengeId in challengeIds) {
      final result = await logActivity(
        challengeId: challengeId,
        type: type,
        activityType: activityType,
        notes: notes,
      );
      results.add(result);
      
      if (!result.success) break;
    }
    
    return results;
  }

  bool canLogForChallenge(String challengeId) {
    return !(challengeProvider.todayLogStatus[challengeId] ?? false);
  }

  List<Challenge> getChallengesNeedingLog() {
    return challengeProvider.challengesNeedingLog;
  }

  bool canTakeRestDay(String challengeId) {
    final userParticipant = challengeProvider.getCurrentUserParticipant(challengeId);
    return userParticipant?.canTakeRestDay ?? false;
  }
}