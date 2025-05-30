// lib/pages/challenge_detail_page.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/widgets/tabs/challenge_media_tab.dart';
import 'package:challengeaccepted/widgets/tabs/challenge_streaks_tab.dart';

class ChallengeDetailPage extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailPage({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(challenge['title'] as String),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo), text: "Media"),
              Tab(icon: Icon(Icons.local_fire_department), text: "Streaks"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChallengeMediaTab(
              challengeId: challenge['id'] as String,
              challengeTitle: challenge['title'] as String,
            ),
            ChallengeStreaksTab(
              challengeId: challenge['id'] as String,
            ),
          ],
        ),
      ),
    );
  }
}