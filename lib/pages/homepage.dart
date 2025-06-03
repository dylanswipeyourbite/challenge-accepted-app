import 'package:challengeaccepted/pages/settings_page.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/widgets/sections/quick_stats_section.dart';
import 'package:challengeaccepted/widgets/sections/quick_actions_section.dart';
import 'package:challengeaccepted/widgets/sections/active_challenges_section.dart';
import 'package:challengeaccepted/widgets/sections/pending_invites_section.dart';
import 'package:challengeaccepted/widgets/sections/timeline_feed_section.dart';
import 'package:challengeaccepted/providers/app_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Use providers to refresh
      context.read<ChallengeProvider>().refresh();
      context.read<UserActivityProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ?? 
                  'https://i.pravatar.cc/150?u=${FirebaseAuth.instance.currentUser?.uid}',
                ),
              ),
            ),
          ),
        ],
      ),
      body: ProviderRefreshIndicator(
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickStatsSection(),
              SizedBox(height: 20),
              QuickActionsSection(),
              SizedBox(height: 20),
              ActiveChallengesSection(),
              SizedBox(height: 20),
              PendingInvitesSection(),
              SizedBox(height: 20),
              TimelineFeedSection(),
            ],
          ),
        ),
      ),
    );
  }
}