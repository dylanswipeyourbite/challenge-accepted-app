import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'env.dart';
import 'package:firebase_auth/firebase_auth.dart';

ValueNotifier<GraphQLClient>? client;

Future<void> initGraphQL() async {
  // final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  final httpLink = HttpLink('http://localhost:4001/graphql', 
  // defaultHeaders: {'Authorization': 'Bearer $idToken'}
  );
  client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );
}

Future<GraphQLClient> createClient() async {
  final httpLink = HttpLink('http://localhost:4001/graphql');

  final authLink = AuthLink(
    getToken: () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print(user.getIdToken());
        return 'Bearer ${await user.getIdToken()}'; // ✅ always fresh
      }
      return null;
    },
  );

  final link = authLink.concat(httpLink);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
  );
}

