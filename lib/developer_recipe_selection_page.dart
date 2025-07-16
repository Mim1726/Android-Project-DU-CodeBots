import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'developers_question_page.dart'; // DChatScreen

/// Shows every recipe that currently has **any** user questions.
/// Tapping a recipe opens the developer chat for that recipe.
class DeveloperRecipeSelectionPage extends StatelessWidget {
  const DeveloperRecipeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Users – Select Recipe'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥  Change this collection path if your chat docs live elsewhere.
        //     Each doc's id is assumed to be the recipeId,
        //     exactly like recipe_details.dart uses.
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No user questions yet 🙂'));
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final recipeId = docs[index].id;
              return ListTile(
                title: Text(recipeId),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DChatScreen(recipeId: recipeId),
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
