// profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';
import 'login_page.dart';
import 'pending_recipes_page.dart';        // Approve Pending Recipes
import 'developers_question_page.dart';   // contains DChatScreen
import 'saved_items.dart';                // View Saved Items
import 'personal_recipes.dart';           // See Personal Recipes

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const List<String> devEmails = [
    'ishratjahan7711@gmail.com',
    'sumitasmia515@gmail.com',
    'mimrobo1726@gmail.com',
    'anikasanzida31593@gmail.com',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('No profile data found')));
        }

        final data      = snapshot.data!.data()!;
        final name      = data['username'] ?? '';
        final email     = data['email']    ?? '';
        final phone     = data['phone']    ?? '';
        final location  = data['location'] ?? '';
        final photoUrl  = data['photoUrl'];

        final userEmail = FirebaseAuth.instance.currentUser!.email ?? '';
        final isDev = devEmails.contains(userEmail);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile', style: TextStyle(color: Colors.deepOrange)),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.deepOrange),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfilePage(initialData: data)),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/screen_images/screen2.jpg', fit: BoxFit.cover),
              SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl) as ImageProvider
                            : const AssetImage('assets/images/default3.jpg'),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(email,
                            style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      const SizedBox(height: 20),
                      if (phone.isNotEmpty) const SizedBox(height: 4),
                      if (phone.isNotEmpty) InfoRow(label: 'Phone', value: phone),
                      if (location.isNotEmpty) InfoRow(label: 'Location', value: location),
                      const SizedBox(height: 30),

                      // ---------- Developer buttons ----------
                      if (isDev) ...[
                        _deepOrangeBtn(
                          text: 'Approve Pending Recipes',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PendingRecipesPage()),
                          ),
                        ),
                        /*
                        const SizedBox(height: 16),
                        _deepOrangeBtn(
                          text: 'Answer Users Question / Q&A',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const DChatScreen(recipeId: ''), // <-- placeholder
                            ),
                          ),
                        ), */
                        const SizedBox(height: 30),
                      ],

                      // ---------- Regular‑user buttons ----------
                      if (!isDev) ...[
                        _deepOrangeBtn(
                          text: 'View Saved Items',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SavedItemsPage()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _deepOrangeBtn(
                          text: 'See Personal Recipes',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PersonalRecipesPage()),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // ---------- Logout ----------
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (_) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Small helper to keep the layout tidy.
  Widget _deepOrangeBtn({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}

// ---------- Simple row for profile fields ----------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
