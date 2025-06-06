// lib/main.dart - Updated to initialize services
import 'package:challengeaccepted/pages/homepage.dart';
import 'package:challengeaccepted/pages/login_page.dart';
import 'package:challengeaccepted/providers/app_providers.dart';
import 'package:challengeaccepted/services/notification_service.dart';
import 'package:challengeaccepted/services/gamification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'graphql_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHiveForFlutter();
  
  // Initialize timezone for notifications
  tz.initializeTimeZones();
  
  // Create GraphQL client
  final graphQLClient = await createClient();
  
  // Initialize services with GraphQL client
  final gamificationService = GamificationService();
  gamificationService.setClient(graphQLClient);
  
  final notificationService = NotificationService();
  notificationService.setClient(graphQLClient);
  await notificationService.initialize();

  runApp(MyApp(
    client: graphQLClient,
    gamificationService: gamificationService,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;
  final GamificationService gamificationService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.client,
    required this.gamificationService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      client: client,
      gamificationService: gamificationService,
      notificationService: notificationService,
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