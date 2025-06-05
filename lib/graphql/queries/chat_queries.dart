class ChatQueries {
  static const String getChatMessages = """
    query GetChatMessages(\$challengeId: ID!, \$limit: Int, \$before: String) {
      chatMessages(challengeId: \$challengeId, limit: \$limit, before: \$before) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
        editedAt
        reactions {
          user {
            id
            displayName
          }
          emoji
          createdAt
        }
        metadata
      }
    }
  """;
}