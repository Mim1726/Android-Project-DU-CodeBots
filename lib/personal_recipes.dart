import 'package:flutter/material.dart';
import 'personal_recipe_details.dart';

class PersonalRecipesPage extends StatefulWidget {
  const PersonalRecipesPage({super.key});

  @override
  State<PersonalRecipesPage> createState() => _PersonalRecipesPageState();
}

class _PersonalRecipesPageState extends State<PersonalRecipesPage> {
  // Initially empty; you can later populate from a database
  final List<Map<String, String>> userRecipes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recipes'),
        backgroundColor: const Color(0xFFFF5722),
      ),
      body: userRecipes.isEmpty
          ? const Center(
        child: Text(
          'You haven’t added any recipes yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userRecipes.length,
        itemBuilder: (context, index) {
          final recipe = userRecipes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(recipe['title'] ?? ''),
              subtitle: Text('${recipe['cuisine']} - ${recipe['description']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalRecipeDetailsPage()),
        ),
        label: const Text('Add More'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF5722),
      ),
    );
  }
}
