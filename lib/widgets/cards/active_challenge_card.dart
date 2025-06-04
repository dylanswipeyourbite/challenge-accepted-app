// lib/widgets/cards/active_challenge_card.dart

import 'package:challengeaccepted/models/challenge.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:flutter/material.dart';

class ActiveChallengeCard extends StatelessWidget {
  final Challenge challenge;  // Changed from Map<String, dynamic>
  final bool needsLogging;

  const ActiveChallengeCard({
    super.key,
    required this.challenge,
    required this.needsLogging,
  });

  @override
  Widget build(BuildContext context) {
    final challengeStatus = _ChallengeStatus.fromChallenge(challenge);
    final participants = challenge.participants;
    final acceptedCount = challenge.acceptedParticipantsCount; // Use computed property
    final timeLimit = challenge.timeLimit;
    final daysRemaining = challenge.daysRemaining;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: needsLogging 
            ? Border.all(color: Colors.orange, width: 3)
            : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: needsLogging ? 5 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(challengeStatus),
              const SizedBox(height: 6),
              _buildTitle(),
              if (needsLogging) _buildNeedsLoggingIndicator(),
              const Spacer(),
              _buildFooter(acceptedCount, daysRemaining),
            ],
          ),
        ),
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
              color: needsLogging 
                  ? Colors.orange.withOpacity(0.2)
                  : status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              needsLogging ? 'LOG TODAY' : status.text,
              style: TextStyle(
                color: needsLogging ? Colors.orange : status.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          challenge.type == ChallengeType.competitive 
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
        challenge.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNeedsLoggingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Activity needed',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        if (challenge.wager?.isNotEmpty ?? false) ...[
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
             challenge.wager ?? '',
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

  // Change this method to accept Challenge instead of Map<String, dynamic>
  factory _ChallengeStatus.fromChallenge(Challenge challenge) {
    switch (challenge.status) {
      case ChallengeStatus.active:
        return const _ChallengeStatus(Colors.green, 'ACTIVE');
      case ChallengeStatus.pending:
        return const _ChallengeStatus(Colors.orange, 'STARTING SOON');
      case ChallengeStatus.completed:
        return const _ChallengeStatus(Colors.blue, 'COMPLETED');
      case ChallengeStatus.expired:
        return _ChallengeStatus(Colors.grey, challenge.status.value.toUpperCase());
    }
  }
}