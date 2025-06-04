// lib/providers/user_activity_provider.dart
import 'package:challengeaccepted/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/user_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/models/user_stats.dart';
import 'package:challengeaccepted/models/active_challenge_info.dart';
import 'package:challengeaccepted/models/media.dart';

class UserActivityProvider extends ChangeNotifier {
  GraphQLClient? _client;
  
  // User stats with typed model
  UserStats? _userStats;
  
  // Timeline media with typed models
  List<Media> _timelineMedia = [];
  
  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingTimeline = false;
  String? _error;
  
  // Getters with typed models
  UserStats? get userStats => _userStats;
  int get currentStreak => _userStats?.currentStreak ?? 0;
  int get totalPoints => _userStats?.totalPoints ?? 0;
  int get completedChallenges => _userStats?.completedChallenges ?? 0;
  ActiveChallengeInfo? get activeChallenge => _userStats?.activeChallenge;
  
  List<Media> get timelineMedia => _timelineMedia;
  bool get isLoading => _isLoadingStats || _isLoadingTimeline;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingTimeline => _isLoadingTimeline;
  String? get error => _error;
  
  // Computed getters
  bool get hasActiveChallenge => activeChallenge != null;
  bool get hasLoggedToday => activeChallenge?.hasLoggedToday ?? false;
  int get remainingRestDays => activeChallenge?.remainingRestDays ?? 0;
  bool get canTakeRestDay => activeChallenge?.canTakeRestDay ?? false;
  
  // Weekly stats (keeping backward compatibility)
  int get weeklyActivityDays => 0; // TODO: Add to UserStats model
  int get weeklyRestDays => activeChallenge?.usedRestDaysThisWeek ?? 0;
  int get weeklyPoints => 0; // TODO: Add to UserStats model
  
  void setClient(GraphQLClient client) {
    _client = client;
  }
  
  // Fetch user stats
  Future<void> fetchUserStats() async {
    if (_client == null) {
      print('UserActivityProvider: GraphQL client not initialized');
      _error = 'Client not initialized';
      notifyListeners();
      return;
    }
    
    _isLoadingStats = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(UserQueries.getUserStats),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        print('UserActivityProvider: GraphQL exception: ${result.exception}');
        _error = result.exception?.graphqlErrors.firstOrNull?.message ?? 
                 result.exception.toString();
      } else {
        final statsData = result.data?['userStats'] as Map<String, dynamic>?;
        if (statsData != null) {
          _userStats = UserStats.fromJson(statsData);
        }
      }
    } catch (e) {
      print('UserActivityProvider: Unexpected error: $e');
      _error = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }
  
  // Fetch timeline media
  Future<void> fetchTimelineMedia() async {
    if (_client == null) return;
    
    _isLoadingTimeline = true;
    notifyListeners();
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(MediaQueries.getTimelineMedia),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );
      
      if (!result.hasException) {
        final mediaData = result.data?['timelineMedia'] as List<dynamic>? ?? [];
        _timelineMedia = mediaData
            .map((json) => Media.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching timeline: $e');
    } finally {
      _isLoadingTimeline = false;
      notifyListeners();
    }
  }
  
  // Update stats after logging activity
  void updateAfterActivityLog({
    required int pointsEarned,
    required int newStreak,
    required String challengeId,
  }) {
    if (_userStats != null) {
      // Create updated stats
      _userStats = UserStats(
        currentStreak: newStreak,
        totalPoints: _userStats!.totalPoints + pointsEarned,
        completedChallenges: _userStats!.completedChallenges,
        activeChallenge: _userStats!.activeChallenge != null &&
                _userStats!.activeChallenge!.id == challengeId
            ? ActiveChallengeInfo(
                id: _userStats!.activeChallenge!.id,
                title: _userStats!.activeChallenge!.title,
                allowedRestDays: _userStats!.activeChallenge!.allowedRestDays,
                usedRestDaysThisWeek: pointsEarned == 5
                    ? _userStats!.activeChallenge!.usedRestDaysThisWeek + 1
                    : _userStats!.activeChallenge!.usedRestDaysThisWeek,
                hasLoggedToday: true,
              )
            : _userStats!.activeChallenge,
      );
    }
    
    notifyListeners();
  }
  
  // Add new media to timeline
  void addMediaToTimeline(Media media) {
    _timelineMedia.insert(0, media);
    notifyListeners();
  }
  
  // Update media interaction (cheer/comment)
  void updateMediaInteraction(String mediaId, {bool? hasCheered, List<Comment>? comments}) {
    final index = _timelineMedia.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      final media = _timelineMedia[index];
      
      if (hasCheered != null || comments != null) {
        // Create updated media object
        _timelineMedia[index] = Media(
          id: media.id,
          challengeId: media.challengeId,
          user: media.user,
          url: media.url,
          type: media.type,
          uploadedAt: media.uploadedAt,
          cheers: hasCheered != null
              ? (hasCheered
                  ? [...media.cheers, 'currentUserId'] // TODO: Get actual user ID
                  : media.cheers.where((id) => id != 'currentUserId').toList())
              : media.cheers,
          comments: comments ?? media.comments,
          hasCheered: hasCheered ?? media.hasCheered,
          caption: media.caption,
          dailyLogId: media.dailyLogId,
          dailyLog: media.dailyLog,
        );
        
        notifyListeners();
      }
    }
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      fetchUserStats(),
      fetchTimelineMedia(),
    ]);
  }
  
  // Clear all data (for logout)
  void clear() {
    _userStats = null;
    _timelineMedia = [];
    _error = null;
    notifyListeners();
  }
}