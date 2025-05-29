class UserMutations {
  static const String createUser = """
    mutation CreateUser(\$input: CreateUserInput!) {
      createUser(input: \$input) {
        id
        displayName
        email
        avatarUrl
      }
    }
  """;
}
