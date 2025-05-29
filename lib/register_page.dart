import 'package:challengeaccepted/graphql/mutations/user_mutations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();

  bool isLoading = false;
  String? error;

Future<void> _register() async {
  setState(() {
    isLoading = true;
    error = null;
  });

  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = credential.user!;
    final displayName = displayNameController.text.trim();
    await user.updateDisplayName(displayName);

    // 🔁 Fetch fresh token (not always required, but safe)
    await user.getIdToken(true);

    // ✅ Call createUser mutation
    final client = GraphQLProvider.of(context).value;

    final avatarUrl = "https://i.pravatar.cc/150?u=${user.uid}"; // optional fallback avatar

    final result = await client.mutate(MutationOptions(
      document: gql(UserMutations.createUser),
      variables: {
        "input": {
          "firebaseUid": user.uid,
          "displayName": displayName,
          "email": user.email,
          "avatarUrl": avatarUrl,
        }
      },
    ));

    if (result.hasException) {
      print('[createUser] ❌ ${result.exception}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created, but backend user sync failed.')),
      );
    }

  } on FirebaseAuthException catch (e) {
    setState(() => error = e.message ?? 'Registration failed');
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
