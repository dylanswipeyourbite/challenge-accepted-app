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
}