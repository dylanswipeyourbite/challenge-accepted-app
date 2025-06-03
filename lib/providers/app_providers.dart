import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/providers/challenge_provider.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';

// Combined provider that initializes with GraphQL client
class AppProviders extends StatelessWidget {
  final Widget child;
  final GraphQLClient client;
  
  const AppProviders({
    super.key,
    required this.child,
    required this.client,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = ChallengeProvider();
            provider.setClient(client);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = UserActivityProvider();
            provider.setClient(client);
            return provider;
          },
        ),
        // Keep existing providers if any
        Provider.value(value: client),
      ],
      child: GraphQLProvider(
        client: ValueNotifier(client),
        child: child,
      ),
    );
  }
}

// Utility widget to auto-fetch data on initialization
class DataInitializer extends StatefulWidget {
  final Widget child;
  
  const DataInitializer({super.key, required this.child});
  
  @override
  State<DataInitializer> createState() => _DataInitializerState();
}

class _DataInitializerState extends State<DataInitializer> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      try {
        final challengeProvider = context.read<ChallengeProvider>();
        final userActivityProvider = context.read<UserActivityProvider>();
        
        // Fetch data in parallel
        await Future.wait([
          challengeProvider.fetchChallenges(),
          challengeProvider.fetchPendingChallenges(),
          userActivityProvider.fetchUserStats(),
          userActivityProvider.fetchTimelineMedia(),
        ]);
      } catch (e) {
        print('Error initializing data: $e');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Extension methods for easy access
extension BuildContextProviders on BuildContext {
  ChallengeProvider get challengeProvider => read<ChallengeProvider>();
  UserActivityProvider get userActivityProvider => read<UserActivityProvider>();
  
  ChallengeProvider watchChallengeProvider() => watch<ChallengeProvider>();
  UserActivityProvider watchUserActivityProvider() => watch<UserActivityProvider>();
}

// Provider-aware refresh widget
class ProviderRefreshIndicator extends StatelessWidget {
  final Widget child;
  final List<String> refreshProviders;
  
  const ProviderRefreshIndicator({
    super.key,
    required this.child,
    this.refreshProviders = const ['challenges', 'userActivity'],
  });
  
  Future<void> _onRefresh(BuildContext context) async {
    final futures = <Future>[];
    
    if (refreshProviders.contains('challenges')) {
      futures.add(context.challengeProvider.refresh());
    }
    
    if (refreshProviders.contains('userActivity')) {
      futures.add(context.userActivityProvider.refresh());
    }
    
    await Future.wait(futures);
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: child,
    );
  }
}