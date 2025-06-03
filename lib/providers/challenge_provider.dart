import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';

class ChallengeProvider extends ChangeNotifier {
  GraphQLClient? _client;
  
  // Challenge data
  List<Map<String, dynamic>> _allChallenges = [];
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _pendingChallenges = [];
  
  // Today's log status for each challenge
  final Map<String, bool> _todayLogStatus = {};
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Map<String, dynamic>> get allChallenges => _allChallenges;
  List<Map<String, dynamic>> get activeChallenges => _activeChallenges;
  List<Map<String, dynamic>> get pendingChallenges => _pendingChallenges;
  Map<String, bool> get todayLogStatus => _todayLogStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed getters
  List<Map<String, dynamic>> get challengesNeedingLog {
    return _activeChallenges.where((challenge) {
      final challengeId = challenge['id'] as String;
      return !(_todayLogStatus[challengeId] ?? false);
    }).toList();
  }
  
  int get challengesNeedingLogCount => challengesNeedingLog.length;
  
  bool get allChallengesLoggedToday {
    if (_activeChallenges.isEmpty) return false;
    return _activeChallenges.every((challenge) {
      final challengeId = challenge['id'] as String;
      return _todayLogStatus[challengeId] ?? false;
    });
  }
  
  void setClient(GraphQLClient client) {
    _client = client;
  }
  
  // Fetch all challenges
  Future<void> fetchChallenges() async {
    if (_client == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(ChallengesQueries.getActiveChallenges),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (result.hasException) {
        _error = result.exception.toString();
      } else {
        _processChallenges(result.data?['challenges'] as List<dynamic>? ?? []);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch pending challenges
  Future<void> fetchPendingChallenges() async {
    if (_client == null) return;
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(ChallengesQueries.pendingChallenges),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      
      if (!result.hasException) {
        _pendingChallenges = List<Map<String, dynamic>>.from(
          result.data?['pendingChallenges'] ?? []
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching pending challenges: $e');
    }
  }
  
  // Process challenges and extract today's log status
  void _processChallenges(List<dynamic> challenges) {
    _allChallenges = List<Map<String, dynamic>>.from(challenges);
    _activeChallenges = [];
    _todayLogStatus.clear();
    
    for (final challenge in challenges) {
      if (challenge['status'] == 'expired') continue;
      
      final participants = challenge['participants'] as List<dynamic>?;
      if (participants == null) continue;
      
      try {
        // Find current user participant
        final currentUserParticipant = participants.firstWhere(
          (p) => p['isCurrentUser'] == true && p['status'] == 'accepted',
        );
        
        if (currentUserParticipant != null) {
          _activeChallenges.add(challenge as Map<String, dynamic>);
          
          // Check today's log status
          final hasLoggedToday = _checkIfLoggedToday(challenge);
          _todayLogStatus[challenge['id'] as String] = hasLoggedToday;
        }
      } catch (_) {
        // User not found in participants
      }
    }
  }
  
  // Check if current user has logged today for a challenge
  bool _checkIfLoggedToday(Map<String, dynamic> challenge) {
    final todayStatus = challenge['todayStatus'] as Map<String, dynamic>?;
    if (todayStatus == null) return false;
    
    final participantsStatus = todayStatus['participantsStatus'] as List?;
    if (participantsStatus == null) return false;
    
    try {
      final currentUserStatus = participantsStatus.firstWhere(
        (status) => status['participant']['isCurrentUser'] == true,
      );
      return currentUserStatus['hasLoggedToday'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }
  
  // Update log status for a challenge
  void updateLogStatus(String challengeId, bool hasLogged) {
    _todayLogStatus[challengeId] = hasLogged;
    notifyListeners();
  }
  
  // Get challenge by ID
  Map<String, dynamic>? getChallengeById(String id) {
    try {
      return _allChallenges.firstWhere((c) => c['id'] == id);
    } catch (_) {
      return null;
    }
  }
  
  // Get current user participant for a challenge
  Map<String, dynamic>? getCurrentUserParticipant(String challengeId) {
    final challenge = getChallengeById(challengeId);
    if (challenge == null) return null;
    
    final participants = challenge['participants'] as List<dynamic>?;
    if (participants == null) return null;
    
    try {
      return participants.firstWhere(
        (p) => p['isCurrentUser'] == true,
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      fetchChallenges(),
      fetchPendingChallenges(),
    ]);
  }
}