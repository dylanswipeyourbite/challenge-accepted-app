// lib/providers/challenge_provider.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/models/participant.dart';

class ChallengeProvider extends ChangeNotifier {
  GraphQLClient? _client;
  
  // Challenge data with typed models
  List<Challenge> _allChallenges = [];
  List<Challenge> _activeChallenges = [];
  List<Challenge> _pendingChallenges = [];
  
  // Today's log status for each challenge
  final Map<String, bool> _todayLogStatus = {};
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // Getters with typed models
  List<Challenge> get allChallenges => _allChallenges;
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Challenge> get pendingChallenges => _pendingChallenges;
  Map<String, bool> get todayLogStatus => _todayLogStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed getters with typed models
  List<Challenge> get challengesNeedingLog {
    return _activeChallenges.where((challenge) {
      return !(_todayLogStatus[challenge.id] ?? false);
    }).toList();
  }
  
  int get challengesNeedingLogCount => challengesNeedingLog.length;
  
  bool get allChallengesLoggedToday {
    if (_activeChallenges.isEmpty) return false;
    return _activeChallenges.every((challenge) {
      return _todayLogStatus[challenge.id] ?? false;
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
        final challengesData = result.data?['challenges'] as List<dynamic>? ?? [];
        _processChallenges(challengesData);
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
        final pendingData = result.data?['pendingChallenges'] as List<dynamic>? ?? [];
        _pendingChallenges = pendingData
            .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching pending challenges: $e');
    }
  }
  
  // Process challenges and extract today's log status
  void _processChallenges(List<dynamic> challengesData) {
    _allChallenges = challengesData
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
    
    _activeChallenges = [];
    _todayLogStatus.clear();
    
    for (final challenge in _allChallenges) {
      if (challenge.isExpired) continue;
      
      // Check if current user is an accepted participant
      final currentUserParticipant = challenge.currentUserParticipant;
      if (currentUserParticipant != null && currentUserParticipant.isAccepted) {
        _activeChallenges.add(challenge);
        
        // Check today's log status
        _todayLogStatus[challenge.id] = challenge.hasCurrentUserLogged;
      }
    }
  }
  
  // Update log status for a challenge
  void updateLogStatus(String challengeId, bool hasLogged) {
    _todayLogStatus[challengeId] = hasLogged;
    notifyListeners();
  }
  
  // Get challenge by ID
  Challenge? getChallengeById(String id) {
    try {
      return _allChallenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // Get current user participant for a challenge
  Participant? getCurrentUserParticipant(String challengeId) {
    final challenge = getChallengeById(challengeId);
    return challenge?.currentUserParticipant;
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      fetchChallenges(),
      fetchPendingChallenges(),
    ]);
  }
}