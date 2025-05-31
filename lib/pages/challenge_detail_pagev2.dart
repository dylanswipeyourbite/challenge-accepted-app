import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/cards/post_card.dart';
import 'package:challengeaccepted/utils/graphql_helpers.dart';
import 'package:challengeaccepted/pages/daily_log_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeDetailPageV2 extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailPageV2({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ChallengesQueries.getChallengeDetails),
        variables: {'id': challenge['id']},
        fetchPolicy: GraphQLHelpers.getFetchPolicyFor(QueryType.challengeDetails),
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (result.hasException) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${result.exception.toString()}'),
            ),
          );
        }

        final challengeData = result.data?['challenge'] as Map<String, dynamic>?;
        if (challengeData == null) {
          return const Scaffold(
            body: Center(child: Text('Challenge not found')),
          );
        }

        return _ChallengeDetailContent(
          challenge: challengeData,
          onRefresh: refetch,
        );
      },
    );
  }
}

class _ChallengeDetailContent extends StatefulWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback? onRefresh;

  const _ChallengeDetailContent({
    required this.challenge,
    this.onRefresh,
  });

  @override
  State<_ChallengeDetailContent> createState() => _ChallengeDetailContentState();
}

class _ChallengeDetailContentState extends State<_ChallengeDetailContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayStatus = widget.challenge['todayStatus'] as Map<String, dynamic>?;
    final challengeStreak = widget.challenge['challengeStreak'] as int? ?? 0;
    final currentUserParticipant = _findCurrentUserParticipant();
    final hasLoggedToday = _hasCurrentUserLoggedToday();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(),
          
          // Challenge Streak Hero Section
          SliverToBoxAdapter(
            child: _ChallengeStreakHero(
              challengeStreak: challengeStreak,
              todayStatus: todayStatus,
            ),
          ),
          
          // Today's Progress Section
          SliverToBoxAdapter(
            child: _TodayProgressSection(
              todayStatus: todayStatus,
              hasLoggedToday: hasLoggedToday,
              onLogActivity: () => _navigateToLogActivity(context),
            ),
          ),
          
          // Participants Status
          SliverToBoxAdapter(
            child: _ParticipantsStatusSection(
              participantsStatus: todayStatus?['participantsStatus'] as List? ?? [],
            ),
          ),

          // NEW: Leaderboard Section
          SliverToBoxAdapter(
            child: _LeaderboardSection(
              participants: widget.challenge['participants'] as List? ?? [],
              challengeType: widget.challenge['type'] as String? ?? '', // Pass the challenge type
            ),
          ),
          
          // Recent Activity Feed
          SliverToBoxAdapter(
            child: _buildRecentActivityHeader(),
          ),
          
          // Media Feed
          _buildMediaFeed(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(hasLoggedToday),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _getSportColor(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.challenge['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getSportColor(),
                _getSportColor().withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSportIcon(),
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.challenge['sport'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        widget.challenge['type'] == 'competitive' 
                            ? Icons.emoji_events 
                            : Icons.group,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.challenge['type'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to full media gallery
            },
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaFeed() {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getMediaByChallenge),
        variables: {'challengeId': widget.challenge['id']},
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

  Widget? _buildFloatingActionButton(bool hasLoggedToday) {
    if (hasLoggedToday || !_showFloatingButton) return null;

    return FloatingActionButton.extended(
      onPressed: () => _navigateToLogActivity(context),
      backgroundColor: Colors.green,
      icon: const Icon(Icons.add),
      label: const Text('Log Activity'),
    );
  }

  Map<String, dynamic>? _findCurrentUserParticipant() {
    final participants = widget.challenge['participants'] as List<dynamic>?;
    if (participants == null) return null;
    
    try {
      return participants.firstWhere(
        (p) => p['isCurrentUser'] == true,
      ) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool _hasCurrentUserLoggedToday() {
    final todayStatus = widget.challenge['todayStatus'] as Map<String, dynamic>?;
    final participantsStatus = todayStatus?['participantsStatus'] as List?;
    
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

  void _navigateToLogActivity(BuildContext context) {
    final participant = _findCurrentUserParticipant();
    if (participant == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IntegratedDailyLogPage(
          challengeId: widget.challenge['id'] as String,
          challengeTitle: widget.challenge['title'] as String,
          userParticipant: participant,
        ),
      ),
    ).then((_) {
      // Force refresh both the challenge and timeline queries
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
      
      // Also refresh the media query
      final client = GraphQLProvider.of(context).value;
      client.query(QueryOptions(
        document: gql(MediaQueries.getMediaByChallenge),
        variables: {'challengeId': widget.challenge['id']},
        fetchPolicy: FetchPolicy.networkOnly,
      ));
    });
  }

  Color _getSportColor() {
    switch (widget.challenge['sport']) {
      case 'running':
        return Colors.orange;
      case 'cycling':
        return Colors.blue;
      case 'workout':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  IconData _getSportIcon() {
    switch (widget.challenge['sport']) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'workout':
        return Icons.fitness_center;
      default:
        return Icons.sports;
    }
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}

// Challenge Streak Hero Widget
class _ChallengeStreakHero extends StatelessWidget {
  final int challengeStreak;
  final Map<String, dynamic>? todayStatus;

  const _ChallengeStreakHero({
    required this.challengeStreak,
    this.todayStatus,
  });

  @override
  Widget build(BuildContext context) {
    final allLogged = todayStatus?['allParticipantsLogged'] as bool? ?? false;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allLogged
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (allLogged ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'Challenge Streak',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$challengeStreak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            challengeStreak == 1 ? 'Day' : 'Days',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          if (allLogged) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'All members logged today!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Today's Progress Section
class _TodayProgressSection extends StatelessWidget {
  final Map<String, dynamic>? todayStatus;
  final bool hasLoggedToday;
  final VoidCallback onLogActivity;

  const _TodayProgressSection({
    this.todayStatus,
    required this.hasLoggedToday,
    required this.onLogActivity,
  });

  @override
  Widget build(BuildContext context) {
    final loggedCount = todayStatus?['participantsLoggedCount'] as int? ?? 0;
    final totalCount = todayStatus?['totalParticipants'] as int? ?? 0;
    final progress = totalCount > 0 ? loggedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$loggedCount/$totalCount logged',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.orange,
              ),
              minHeight: 8,
            ),
          ),
          if (!hasLoggedToday) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogActivity,
                icon: const Icon(Icons.add),
                label: const Text('Log Your Activity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Participants Status Section
class _ParticipantsStatusSection extends StatelessWidget {
  final List participantsStatus;

  const _ParticipantsStatusSection({
    required this.participantsStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (participantsStatus.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Members Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...participantsStatus.map((status) {
            final participant = status['participant'] as Map<String, dynamic>;
            final user = participant['user'] as Map<String, dynamic>?;
            final hasLogged = status['hasLoggedToday'] as bool? ?? false;
            final isCurrentUser = participant['isCurrentUser'] as bool? ?? false;
            
            return _ParticipantStatusTile(
              displayName: user?['displayName'] as String? ?? 'Unknown',
              avatarUrl: user?['avatarUrl'] as String?,
              hasLoggedToday: hasLogged,
              isCurrentUser: isCurrentUser,
              lastLogTime: _parseDateTime(status['lastLogTime']),
            );
          }).toList(),
        ],
      ),
    );
  }

  DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr as String);
  }
}

// Participant Status Tile
class _ParticipantStatusTile extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final bool hasLoggedToday;
  final bool isCurrentUser;
  final DateTime? lastLogTime;

  const _ParticipantStatusTile({
    required this.displayName,
    this.avatarUrl,
    required this.hasLoggedToday,
    required this.isCurrentUser,
    this.lastLogTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasLoggedToday 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLoggedToday
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: avatarUrl != null 
                ? NetworkImage(avatarUrl!)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: avatarUrl == null 
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasLoggedToday 
                      ? 'Logged today ${_formatTime(lastLogTime)}'
                      : 'Not logged yet',
                  style: TextStyle(
                    color: hasLoggedToday 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasLoggedToday ? Icons.check_circle : Icons.circle_outlined,
            color: hasLoggedToday ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '';
  }
}

// Add this widget class at the bottom of the file
class _LeaderboardSection extends StatelessWidget {
  final List<dynamic> participants;
  final String challengeType; // Add this parameter

  const _LeaderboardSection({
    required this.participants,
    required this.challengeType, // Add this to constructor
  });

  @override
  Widget build(BuildContext context) {
    // Filter and sort participants by total points
    final rankedParticipants = participants
        .where((p) => p['status'] == 'accepted')
        .toList()
      ..sort((a, b) {
        final pointsA = a['totalPoints'] as int? ?? 0;
        final pointsB = b['totalPoints'] as int? ?? 0;
        return pointsB.compareTo(pointsA); // Descending order
      });

    if (rankedParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (challengeType == 'competitive') // Use the parameter instead of widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMPETITIVE',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...rankedParticipants.asMap().entries.map((entry) {
            final index = entry.key;
            final participant = entry.value as Map<String, dynamic>;
            return _LeaderboardTile(
              rank: index + 1,
              participant: participant,
              isCurrentUser: participant['isCurrentUser'] as bool? ?? false,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> participant;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.participant,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final user = participant['user'] as Map<String, dynamic>?;
    final totalPoints = participant['totalPoints'] as int? ?? 0;
    final dailyStreak = participant['dailyStreak'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.blue.withOpacity(0.1)
            : rank <= 3
                ? Colors.amber.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? Colors.blue.withOpacity(0.3)
              : rank <= 3
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      rank == 1
                          ? Icons.looks_one
                          : rank == 2
                              ? Icons.looks_two
                              : Icons.looks_3,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            backgroundImage: user?['avatarUrl'] != null
                ? NetworkImage(user!['avatarUrl'] as String)
                : null,
            backgroundColor: Colors.grey.shade300,
            radius: 20,
            child: user?['avatarUrl'] == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?['displayName'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$dailyStreak day streak',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalPoints.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }
}