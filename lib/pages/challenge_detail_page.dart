// lib/pages/challenge_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/pages/daily_log_page.dart';
import 'package:challengeaccepted/pages/challenge_analytics_page.dart';
import 'package:challengeaccepted/pages/challenge_calender_page.dart';
import 'package:challengeaccepted/pages/challenge_chat_page.dart';
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

  Future<void> _navigateToDailyLog(BuildContext context) async {
    // Store providers before navigation
    final challengeProvider = context.read<ChallengeProvider>();
    final userActivityProvider = context.read<UserActivityProvider>();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderAwareDailyLogPage(
          challengeId: challengeId,
          onComplete: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
    
    if (result == true) {
      // Use stored providers after navigation completes
      await Future.delayed(const Duration(milliseconds: 100));
      await Future.wait([
        challengeProvider.refresh(),
        userActivityProvider.refresh(),
      ]);
    }
  }

  void _showMoreOptions(BuildContext context, Challenge challenge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Colors.blue),
              ),
              title: const Text('View Analytics'),
              subtitle: const Text('Track your progress and patterns'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeAnalyticsPage(challengeId: challengeId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.green),
              ),
              title: const Text('Activity Calendar'),
              subtitle: const Text('View your activity history'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeCalendarPage(challengeId: challengeId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble, color: Colors.purple),
              ),
              title: const Text('Challenge Chat'),
              subtitle: const Text('Chat with challenge members'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeChatPage(challengeId: challengeId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
              // Custom App Bar with actions
              _buildSliverAppBar(context, challenge),
              
              // Challenge Streak Hero Section
              SliverToBoxAdapter(
                child: ChallengeStreakHero(challengeId: challengeId),
              ),
              
              // Quick action buttons
              SliverToBoxAdapter(
                child: _buildQuickActions(context, challenge),
              ),
              
              // Today's Progress Section
              SliverToBoxAdapter(
                child: TodayProgressSection(
                  challengeId: challengeId,
                  onLogActivity: () => _navigateToDailyLog(context),
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
                  onPressed: () => _navigateToDailyLog(context),
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.add),
                  label: const Text('Log Activity'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Challenge challenge) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: challenge.sport.color,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context, challenge),
        ),
      ],
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

  Widget _buildQuickActions(BuildContext context, Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.analytics,
              label: 'Analytics',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengeAnalyticsPage(challengeId: challengeId),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.calendar_month,
              label: 'Calendar',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengeCalendarPage(challengeId: challengeId),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.chat_bubble,
              label: 'Chat',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengeChatPage(challengeId: challengeId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}