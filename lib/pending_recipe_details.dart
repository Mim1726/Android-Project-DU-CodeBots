import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingRecipeDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot recipe;

  const PendingRecipeDetailsPage({super.key, required this.recipe});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Could show error snackbar or dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = recipe.data() as Map<String, dynamic>;

    final base64Image = data['imageBase64'] as String?;
    ImageProvider? imageProvider;

    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Image);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }

    final ingredients = data['ingredients'] as String? ?? 'No ingredients';
    final amounts = data['amounts'] as String? ?? '';
    final ingredientsWithAmounts = amounts.isNotEmpty
        ? List.generate(
      ingredients.split('\n').length,
          (i) {
        final ingredientLines = ingredients.split('\n');
        final amountLines = amounts.split('\n');
        final ingredient = i < ingredientLines.length ? ingredientLines[i] : '';
        final amount = i < amountLines.length ? amountLines[i] : '';
        if (ingredient.isNotEmpty && amount.isNotEmpty) {
          return '$ingredient = $amount';
        } else {
          return ingredient.isNotEmpty ? ingredient : '';
        }
      },
    ).where((line) => line.isNotEmpty).join('\n')
        : ingredients;

    final youtubeLink = data['youtubeLink'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Recipe Details'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (imageProvider != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            const SizedBox(height: 16),
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            Text(data['description'] ?? 'No description'),
            const SizedBox(height: 16),
            Text('Duration', style: Theme.of(context).textTheme.titleLarge),
            Text(data['duration'] ?? 'Not specified'),
            const SizedBox(height: 16),
            Text('Meal Type', style: Theme.of(context).textTheme.titleLarge),
            Text(data['mealType'] ?? 'Not specified'),
            const SizedBox(height: 16),
            Text('Cuisine', style: Theme.of(context).textTheme.titleLarge),
            Text(data['cuisine'] ?? 'Not specified'),
            const SizedBox(height: 16),
            Text('Ingredients & Amounts', style: Theme.of(context).textTheme.titleLarge),
            Text(ingredientsWithAmounts),
            const SizedBox(height: 16),
            Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
            Text(data['instructions'] ?? 'No instructions'),
            if (youtubeLink.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('YouTube Video', style: Theme.of(context).textTheme.titleLarge),
              GestureDetector(
                onTap: () => _launchURL(youtubeLink),
                child: Text(
                  youtubeLink,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
