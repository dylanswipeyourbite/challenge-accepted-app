class CommentsMutations {
  static const String addComment = """
    mutation AddComment(\$input: AddCommentInput!) {
      addComment(input: \$input) {
        id
        text
        createdAt
        author {
          displayName
          avatarUrl
        }
      }
    }
  """;
}
