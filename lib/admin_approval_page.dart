import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalPage extends StatelessWidget {
  const AdminApprovalPage({super.key});

  Future<void> approveRecipe(String docId) async {
    await FirebaseFirestore.instance
        .collection('pending_recipes')
        .doc(docId)
        .update({'approved': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Recipes'),
        backgroundColor: const Color(0xFFFF5722),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_recipes')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data!.docs;

          if (recipes.isEmpty) {
            return const Center(child: Text('No pending recipes'));
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final doc = recipes[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(doc['title']),
                  subtitle: Text(doc['description']),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => approveRecipe(doc.id),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
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
