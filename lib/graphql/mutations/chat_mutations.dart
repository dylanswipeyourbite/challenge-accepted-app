class ChatMutations {
  static const String sendMessage = """
    mutation SendChatMessage(\$input: SendMessageInput!) {
      sendChatMessage(input: \$input) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
        reactions {
          user {
            id
          }
          emoji
        }
        metadata
      }
    }
  """;

  static const String addReaction = """
    mutation AddReaction(\$input: AddReactionInput!) {
      addReaction(input: \$input) {
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

  static const String removeReaction = """
    mutation RemoveReaction(\$messageId: ID!, \$emoji: String!) {
      removeReaction(messageId: \$messageId, emoji: \$emoji) {
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