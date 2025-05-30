import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTokenDebug extends StatefulWidget {
  const FirebaseTokenDebug({super.key});

  @override
  State<FirebaseTokenDebug> createState() => _FirebaseTokenDebugState();
}

class _FirebaseTokenDebugState extends State<FirebaseTokenDebug> {
  String? _token;
  bool _loading = false;

  Future<void> _getToken() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final token = await user.getIdToken();
      setState(() => _token = token);
    } else {
      setState(() => _token = '⚠️ Not signed in.');
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _getToken(); // Automatically fetch on open
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Token Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SelectableText(
                _token ?? 'No token yet.',
                style: const TextStyle(fontSize: 12),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getToken,
        tooltip: 'Refresh Token',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
