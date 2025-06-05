// lib/pages/challenge_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/utils/navigation_helper.dart';
import 'package:challengeaccepted/widgets/provider_aware/challenge_streak_hero.dart';
import 'package:challengeaccepted/widgets/provider_aware/today_progress_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/participants_status_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/leaderboard_section.dart';
import 'package:challengeaccepted/widgets/provider_aware/challenge_media_feed.dart';

class ChallengeDetailPage extends StatelessWidget {
  final String challengeId;

  const ChallengeDetailPage({
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

  Widget _buildSliverAppBar(Challenge challenge) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: challenge.sport.color,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          challenge.title,
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
                challenge.sport.color,
                challenge.sport.color.withOpacity(0.7),
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
                        challenge.sport.icon,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        challenge.sport.value.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        challenge.type.icon,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        challenge.type.value.toUpperCase(),
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
}