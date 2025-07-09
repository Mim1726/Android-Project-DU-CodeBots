import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details.dart';

class SavedItemsPage extends StatelessWidget {
  const SavedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange, // 🔶 Deep orange color
        foregroundColor: Colors.white, // Make text/icons white for contrast
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('saved_recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No saved recipes.'));
          }

          final savedRecipes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedRecipes.length,
            itemBuilder: (context, index) {
              final recipeData = savedRecipes[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: recipeData['imageName'] != null
                      ? Image.asset(
                    'assets/images/${recipeData['imageName']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.food_bank),
                  title: Text(recipeData['title'] ?? ''),
                  subtitle: recipeData['duration'] != null
                      ? Text('${recipeData['duration']} mins')
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipeData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
