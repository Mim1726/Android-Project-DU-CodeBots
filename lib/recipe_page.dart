import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details.dart';
import 'side_navigation.dart';

class CuisineRecipePage extends StatefulWidget {
  final String cuisineName;

  const CuisineRecipePage({super.key, required this.cuisineName});

  @override
  State<CuisineRecipePage> createState() => _CuisineRecipePageState();
}

class _CuisineRecipePageState extends State<CuisineRecipePage> {
  List<Map<String, dynamic>> _recipes = [];
  String _search = '';
  bool _loading = false;

  final Map<String, String> localRecipeImages = {
    "Butter Chicken": "assets/images/butter-chicken.jpg",
    "Paneer Tikka": "assets/images/paneer-tikka.png",
  };

  Future<void> fetchRecipes() async {
    setState(() {
      _loading = true;
    });

    try {
      Query collectionQuery = FirebaseFirestore.instance.collection('recipes');

      // Filter by cuisine
      collectionQuery = collectionQuery.where('cuisine', isEqualTo: widget.cuisineName);

      // Optional: Search by title prefix
      if (_search.isNotEmpty) {
        collectionQuery = collectionQuery
            .where('title', isGreaterThanOrEqualTo: _search)
            .where('title', isLessThanOrEqualTo: '$_search\uf8ff');
      }

      QuerySnapshot querySnapshot = await collectionQuery.get();

      final recipesData = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _recipes = List<Map<String, dynamic>>.from(recipesData);
      });
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      setState(() {
        _recipes = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cuisineName} Recipes'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const SideNavigationDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ${widget.cuisineName} recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _search = value.trim());
                fetchRecipes();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                ? const Center(child: Text("No recipes found."))
                : ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                final String? title = recipe['title'];
                final String? imageName = recipe['imageName'];
                final String assetPath = title != null && localRecipeImages.containsKey(title)
                    ? localRecipeImages[title]!
                    : imageName != null
                    ? 'assets/images/$imageName'
                    : 'assets/default.jpg';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                    leading: Image.asset(
                      assetPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(recipe['title'] ?? ''),
                    subtitle: recipe['duration'] != null
                        ? Text('${recipe['duration']} mins')
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
