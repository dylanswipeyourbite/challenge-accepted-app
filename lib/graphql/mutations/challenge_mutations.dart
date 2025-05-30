class ChallengeMutations {
  static const String acceptChallenge = """
    mutation AcceptChallenge(\$challengeId: ID!, \$restDays: Int!) {
      acceptChallenge(challengeId: \$challengeId, restDays: \$restDays) {
        id
        user {
          id
          displayName
        }
        role
        status
        restDays
        joinedAt
      }
    }
    """;

  static const String declineChallenge = """
    mutation DeclineChallenge(\$challengeId: ID!, \$reason: String) {
      declineChallenge(challengeId: \$challengeId, reason: \$reason)
    }
    """;
}