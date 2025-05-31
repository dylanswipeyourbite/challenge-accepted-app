// lib/widgets/cards/active_challenge_card.dart

import 'package:challengeaccepted/pages/challenge_detail_pagev2.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/pages/challenge_detail_page.dart';

class ActiveChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ActiveChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final challengeStatus = _ChallengeStatus.fromChallenge(challenge);
    final participants = challenge['participants'] as List<dynamic>? ?? [];
    final acceptedCount = participants.where((p) => p['status'] == 'accepted').length;
    final timeLimit = DateTime.tryParse(challenge['timeLimit'] as String? ?? '');
    final daysRemaining = timeLimit?.difference(DateTime.now()).inDays ?? 0;
    
    return InkWell(
      onTap: () => _navigateToDetail(context),
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        elevation: 3,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(challengeStatus),
              const SizedBox(height: 6),
              _buildTitle(),
              const Spacer(),
              _buildFooter(acceptedCount, daysRemaining),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailPageV2(challenge: challenge),
      ),
    );
  }

  Widget _buildHeader(_ChallengeStatus status) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.text,
              style: TextStyle(
                color: status.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          challenge['type'] == 'competitive' 
              ? Icons.emoji_events 
              : Icons.group,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        challenge['title'] as String,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(int acceptedCount, int daysRemaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(
          Icons.people,
          "$acceptedCount participants",
        ),
        if (daysRemaining > 0) ...[
          const SizedBox(height: 2),
          _buildInfoRow(
            Icons.timer,
            "$daysRemaining days left",
          ),
        ],
        if (challenge['wager'] != null && (challenge['wager'] as String).isNotEmpty) ...[
          const SizedBox(height: 2),
          _buildWagerRow(),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWagerRow() {
    return Row(
      children: [
        const Icon(Icons.local_offer, size: 12, color: Colors.orange),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            challenge['wager'] as String,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ChallengeStatus {
  final Color color;
  final String text;

  const _ChallengeStatus(this.color, this.text);

  factory _ChallengeStatus.fromChallenge(Map<String, dynamic> challenge) {
    final status = challenge['status'] as String? ?? 'pending';
    
    switch (status) {
      case 'active':
        return const _ChallengeStatus(Colors.green, 'ACTIVE');
      case 'pending':
        return const _ChallengeStatus(Colors.orange, 'STARTING SOON');
      case 'completed':
        return const _ChallengeStatus(Colors.blue, 'COMPLETED');
      default:
        return _ChallengeStatus(Colors.grey, status.toUpperCase());
    }
  }
}