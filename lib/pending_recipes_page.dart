import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'personal_recipe_details.dart';

class PendingRecipesPage extends StatelessWidget {
  const PendingRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pending Recipes'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_recipes')
            .where('authorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('You have no recipes awaiting approval.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc  = docs[index] as QueryDocumentSnapshot<Map<String,dynamic>>;
              final data = doc.data();
              final title = data['title'] ?? 'Untitled';
              final ts    = data['createdAt'] as Timestamp?;
              final date  = ts != null ? ts.toDate() : null;

              return ListTile(
                title: Text(title),
                subtitle: date != null
                    ? Text('Submitted on ${date.toLocal().toString().split(' ').first}')
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalRecipeDetailsPage(recipe: doc),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
