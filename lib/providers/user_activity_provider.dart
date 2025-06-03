import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/user_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';

class UserActivityProvider extends ChangeNotifier {
  GraphQLClient? _client;
  
  // User stats
  int _currentStreak = 0;
  int _totalPoints = 0;
  int _completedChallenges = 0;
  
  // Active challenge info
  Map<String, dynamic>? _activeChallenge;
  
  // Weekly activity summary
  int _weeklyActivityDays = 0;
  int _weeklyRestDays = 0;
  int _weeklyPoints = 0;
  
  // Timeline media
  List<Map<String, dynamic>> _timelineMedia = [];
  
  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingTimeline = false;
  String? _error;
  
  // Getters
  int get currentStreak => _currentStreak;
  int get totalPoints => _totalPoints;
  int get completedChallenges => _completedChallenges;
  Map<String, dynamic>? get activeChallenge => _activeChallenge;
  int get weeklyActivityDays => _weeklyActivityDays;
  int get weeklyRestDays => _weeklyRestDays;
  int get weeklyPoints => _weeklyPoints;
  List<Map<String, dynamic>> get timelineMedia => _timelineMedia;
  bool get isLoading => _isLoadingStats || _isLoadingTimeline;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingTimeline => _isLoadingTimeline;
  String? get error => _error;
  
  // Computed getters
  bool get hasActiveChallenge => _activeChallenge != null;
  
  bool get hasLoggedToday => _activeChallenge?['hasLoggedToday'] ?? false;
  
  int get remainingRestDays {
    if (_activeChallenge == null) return 0;
    final allowed = _activeChallenge!['allowedRestDays'] as int? ?? 1;
    final used = _activeChallenge!['usedRestDaysThisWeek'] as int? ?? 0;
    return allowed - used;
  }
  
  bool get canTakeRestDay => remainingRestDays > 0;
  
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
        _processUserStats(result.data?['userStats'] as Map<String, dynamic>?);
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
        _timelineMedia = List<Map<String, dynamic>>.from(
          result.data?['timelineMedia'] ?? []
        );
      }
    } catch (e) {
      print('Error fetching timeline: $e');
    } finally {
      _isLoadingTimeline = false;
      notifyListeners();
    }
  }
  
  // Process user stats from GraphQL response
  void _processUserStats(Map<String, dynamic>? stats) {
    if (stats == null) return;
    
    _currentStreak = stats['currentStreak'] as int? ?? 0;
    _totalPoints = stats['totalPoints'] as int? ?? 0;
    _completedChallenges = stats['completedChallenges'] as int? ?? 0;
    _activeChallenge = stats['activeChallenge'] as Map<String, dynamic>?;
  }
  
  // Update stats after logging activity
  void updateAfterActivityLog({
    required int pointsEarned,
    required int newStreak,
    required String challengeId,
  }) {
    _totalPoints += pointsEarned;
    _currentStreak = newStreak;
    
    if (_activeChallenge != null && _activeChallenge!['id'] == challengeId) {
      _activeChallenge!['hasLoggedToday'] = true;
      
      if (pointsEarned == 5) {
        // Rest day
        final used = _activeChallenge!['usedRestDaysThisWeek'] as int? ?? 0;
        _activeChallenge!['usedRestDaysThisWeek'] = used + 1;
        _weeklyRestDays++;
      } else {
        // Activity day
        _weeklyActivityDays++;
      }
    }
    
    _weeklyPoints += pointsEarned;
    notifyListeners();
  }
  
  // Add new media to timeline
  void addMediaToTimeline(Map<String, dynamic> media) {
    _timelineMedia.insert(0, media);
    notifyListeners();
  }
  
  // Update media interaction (cheer/comment)
  void updateMediaInteraction(String mediaId, {bool? hasCheered, List? comments}) {
    final index = _timelineMedia.indexWhere((m) => m['id'] == mediaId);
    if (index != -1) {
      if (hasCheered != null) {
        _timelineMedia[index]['hasCheered'] = hasCheered;
        
        // Update cheers count
        final cheers = _timelineMedia[index]['cheers'] as List? ?? [];
        if (hasCheered && !cheers.contains('currentUserId')) {
          _timelineMedia[index]['cheers'] = [...cheers, 'currentUserId'];
        } else if (!hasCheered) {
          _timelineMedia[index]['cheers'] = 
            cheers.where((id) => id != 'currentUserId').toList();
        }
      }
      
      if (comments != null) {
        _timelineMedia[index]['comments'] = comments;
      }
      
      notifyListeners();
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
    _currentStreak = 0;
    _totalPoints = 0;
    _completedChallenges = 0;
    _activeChallenge = null;
    _weeklyActivityDays = 0;
    _weeklyRestDays = 0;
    _weeklyPoints = 0;
    _timelineMedia = [];
    _error = null;
    notifyListeners();
  }
}