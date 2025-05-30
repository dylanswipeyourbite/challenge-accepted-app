import 'package:challengeaccepted/pages/change_password_page.dart';
import 'package:challengeaccepted/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.of(context).pop();
  }

  void _editProfile(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const EditProfilePage(),
    ));
  }

  void _changePassword(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ChangePasswordPage(),
    ));
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action is permanent and cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Ask for password
    final password = await _promptPassword(context);
    if (password == null || password.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception("User not logged in");

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Account deleted.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to delete account: $e')),
      );
    }
  }
    
  Future<String?> _promptPassword(BuildContext context) async {
    String password = '';
    return await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter your password'),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, password), child: const Text('Continue')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.photoURL ?? "https://i.pravatar.cc/150?u=${user.uid}",
                    ),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? 'Anonymous', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32),
            ],

            ElevatedButton(
              onPressed: () => _editProfile(context),
              child: const Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('Change Password'),
            ),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
