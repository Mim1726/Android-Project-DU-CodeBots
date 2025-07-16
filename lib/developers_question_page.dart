// developer_question_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'developers_reply_page.dart';

class DChatScreen extends StatelessWidget {
  final String recipeId;

  const DChatScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the body background image to extend under the AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white, // Title block now white
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Developer Questions',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          // Background image (no blur, no dark overlay)
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen8.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Main content overlay wrapped in SafeArea so it's not hidden under the AppBar
          SafeArea(
            child: _buildQuestionList(context),
          ),
        ],
      ),
    );
  }

  /// Builds the list of questions inside white cards.
  Widget _buildQuestionList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .collection('qa')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final questions = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final doc = questions[index];
            final questionId = doc.id;

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(recipeId)
                  .collection('qa')
                  .doc(questionId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .get(),
              builder: (context, messageSnapshot) {
                if (!messageSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      child: ListTile(title: Text('Loading...')),
                    ),
                  );
                }

                final allMessages = messageSnapshot.data!.docs;

                final bool anyUnseenUserMessage = allMessages.any((mDoc) {
                  final data = mDoc.data() as Map<String, dynamic>;
                  return data['senderType'] == 'user' && data['seen'] != true;
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Card(
                    color: Colors.white, // Each question in its own white box
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Question from UID: ${doc['askedBy']}'),
                      subtitle: Text(
                        anyUnseenUserMessage ? 'Unseen — Tap to reply' : 'Seen',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DChatReplyPage(
                              recipeId: recipeId,
                              questionId: questionId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
