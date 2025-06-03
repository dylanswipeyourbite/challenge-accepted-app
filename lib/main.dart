import 'package:challengeaccepted/pages/homepage.dart';
import 'package:challengeaccepted/pages/login_page.dart';
import 'package:challengeaccepted/providers/app_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHiveForFlutter();
  final graphQLClient = await createClient();

  runApp(MyApp(client: graphQLClient));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;

  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      client: client,
      child: MaterialApp(
        title: 'Challenge Accepted',
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              return const DataInitializer(
                child: HomeDashboardPage(),
              );
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}