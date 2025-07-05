// dChatScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dChatReplyPage.dart';

class DChatScreen extends StatelessWidget {
  final String recipeId;

  const DChatScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Questions'),
        backgroundColor: const Color(0xFFB7351F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId)
            .collection('qa')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final doc = questions[index];
              return ListTile(
                title: Text("Question from UID: ${doc['askedBy']}"),
                subtitle: Text("Tap to reply"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DChatReplyPage(
                        recipeId: recipeId,
                        questionId: doc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

