// lib/models/processed_challenge.dart
import 'package:challengeaccepted/models/challenge.dart';

class ProcessedChallenge {
  final Challenge challenge;
  final bool needsLogging;

  const ProcessedChallenge({
    required this.challenge,
    required this.needsLogging,
  });
}