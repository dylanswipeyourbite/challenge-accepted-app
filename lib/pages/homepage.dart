import 'package:challengeaccepted/pages/settings_page.dart';
import 'package:challengeaccepted/widgets/sections/quick_stats_section.dart';
import 'package:challengeaccepted/widgets/sections/quick_actions_section.dart';
import 'package:challengeaccepted/widgets/sections/active_challenges_section.dart';
import 'package:challengeaccepted/widgets/sections/pending_invites_section.dart';
import 'package:challengeaccepted/widgets/sections/timeline_feed_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

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
      body: const SingleChildScrollView(
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
    );
  }
}