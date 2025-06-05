class ChatSubscriptions {
  static const String onChatMessage = """
    subscription OnChatMessage(\$challengeId: ID!) {
      chatMessageAdded(challengeId: \$challengeId) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
        metadata
      }
    }
  """;

  static const String onMessageUpdated = """
    subscription OnMessageUpdated(\$challengeId: ID!) {
      chatMessageUpdated(challengeId: \$challengeId) {
        id
        reactions {
          user {
            id
            displayName
          }
          emoji
          createdAt
        }
      }
    }
  """;
}