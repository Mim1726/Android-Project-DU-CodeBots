import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'edit_profile_page.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _clearStorage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Storage"),
        content: const Text("This will remove all saved items. Proceed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear")),
        ],
      ),
    );

    if (confirm == true) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (userId != null) {
        try {
          final savedRecipes = await FirebaseFirestore.instance
              .collection('saved_recipes')
              .where('userId', isEqualTo: userId)
              .get();

          for (var doc in savedRecipes.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          debugPrint("Error clearing saved recipes: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage and saved items cleared")),
      );
    }
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Logout")),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  void _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is currently logged in.")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Text("Send a password reset email to:\n$email ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Send")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send email: $e")),
        );
      }
    }
  }

  void _shareAppLink() {
    Share.share("Check out our awesome recipe app: https://play.google.com/store/apps/details?id=com.yourapp.package");
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: const SingleChildScrollView(
          child: Text(
            "By using this app, you agree to the following terms:\n\n"
                "1. Your data is stored securely using Firebase.\n"
                "2. Recipes you save are visible only to you.\n"
                "3. You agree not to upload offensive or plagiarized content.\n"
                "4. The app may collect anonymous usage data for improving user experience.\n"
                "5. We reserve the right to update these terms at any time.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("I Agree"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.edit, color: Colors.deepOrange),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage(initialData: {},)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock, color: Colors.deepOrange),
            title: const Text("Change Password"),
            onTap: () => _handlePasswordReset(context),
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.deepOrange),
            title: const Text("Delete Account"),
            onTap: () => _deleteAccount(context),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.deepOrange),
            title: const Text("Clear Storage"),
            subtitle: const Text("Will remove recipes from saved items"),
            onTap: () => _clearStorage(context),
          ),

          ListTile(
            leading: const Icon(Icons.share, color: Colors.deepOrange),
            title: const Text("Share App Link"),
            onTap: _shareAppLink,
          ),

          ListTile(
            leading: const Icon(Icons.info, color: Colors.deepOrange),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.article, color: Colors.deepOrange),
            title: const Text("Terms & Conditions"),
            onTap: () => _showTermsAndConditions(context),
          ),

          const Divider(),

          // 🔚 Logout now at the bottom
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.deepOrange),
            title: const Text("Logout"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
