import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/utils/navigation_helper.dart';
import 'package:challengeaccepted/widgets/provider_aware/challenge_streak_hero.dart';
import 'package:challengeaccepted/widgets/provider_aware/today_progress_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/participants_status_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/leaderboard_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/challenge_media_feed.dart';

class ProviderAwareChallengeDetailPage extends StatelessWidget {
  final String challengeId;

  const ProviderAwareChallengeDetailPage({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.getChallengeById(challengeId);
        
        if (challenge == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Challenge not found'),
            ),
          );
        }

        final hasLoggedToday = provider.todayLogStatus[challengeId] ?? false;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Custom App Bar
              _buildSliverAppBar(challenge),
              
              // Challenge Streak Hero Section
              SliverToBoxAdapter(
                child: ChallengeStreakHero(challengeId: challengeId),
              ),
              
              // Today's Progress Section
              SliverToBoxAdapter(
                child: TodayProgressSection(
                  challengeId: challengeId,
                  onLogActivity: () => NavigationHelper.navigateToDailyLog(context, challengeId),
                ),
              ),
              
              // Participants Status
              SliverToBoxAdapter(
                child: ParticipantsStatusSection(challengeId: challengeId),
              ),

              // Leaderboard Section
              SliverToBoxAdapter(
                child: LeaderboardSection(challengeId: challengeId),
              ),
              
              // Recent Activity Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Media Feed
              ChallengeMediaFeed(challengeId: challengeId),
            ],
          ),
          floatingActionButton: !hasLoggedToday
              ? FloatingActionButton.extended(
                  onPressed: () => NavigationHelper.navigateToDailyLog(context, challengeId),
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.add),
                  label: const Text('Log Activity'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> challenge) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _getSportColor(challenge['sport'] as String),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          challenge['title'] as String,
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
                _getSportColor(challenge['sport'] as String),
                _getSportColor(challenge['sport'] as String).withOpacity(0.7),
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
                        _getSportIcon(challenge['sport'] as String),
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (challenge['sport'] as String).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        challenge['type'] == 'competitive' 
                            ? Icons.emoji_events 
                            : Icons.group,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (challenge['type'] as String).toUpperCase(),
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

  Color _getSportColor(String sport) {
    switch (sport) {
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

  IconData _getSportIcon(String sport) {
    switch (sport) {
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
}