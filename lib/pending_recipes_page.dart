import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pending_recipe_details.dart';

class PendingRecipesPage extends StatelessWidget {
  const PendingRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Pending Recipes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen8.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // White overlay
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.8)),
          ),

          // Main content
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pending_recipes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recipes awaiting approval.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final authorName = data['authorName'] ?? 'Unknown';
                    final ts = data['createdAt'] as Timestamp?;
                    final date = ts?.toDate();
                    final formattedDate = date != null
                        ? 'Submitted on ${date.toLocal().toString().split(' ').first}'
                        : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text('$formattedDate\nBy: $authorName'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'approve') {
                                _approveRecipe(context, doc);
                              } else if (value == 'reject') {
                                _rejectRecipe(context, doc);
                              } else if (value == 'details') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PendingRecipeDetailsPage(recipe: doc),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(value: 'details', child: Text('See Details')),
                              PopupMenuItem(value: 'approve', child: Text('Approve')),
                              PopupMenuItem(value: 'reject', child: Text('Reject')),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PendingRecipeDetailsPage(recipe: doc),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRecipe(BuildContext context, QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final approvedData = Map<String, dynamic>.from(data)
      ..remove('approved')
      ..['likes'] = 0;

    try {
      await FirebaseFirestore.instance.collection('recipes').add(approvedData);
      await FirebaseFirestore.instance.collection('pending_recipes').doc(doc.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe approved and published')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving recipe: $e')),
      );
    }
  }

  Future<void> _rejectRecipe(BuildContext context, QueryDocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Recipe'),
        content: const Text('Are you sure you want to reject and delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('pending_recipes')
            .doc(doc.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe rejected and removed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting recipe: $e')),
        );
      }
    }
  }
}
