import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details.dart';
import 'side_navigation.dart';

class CuisineRecipePage extends StatefulWidget {
  final String? cuisineName;

  const CuisineRecipePage({super.key, this.cuisineName});

  // Global search page constructor
  const CuisineRecipePage.search({super.key}) : cuisineName = null;

  @override
  State<CuisineRecipePage> createState() => _CuisineRecipePageState();
}

class _CuisineRecipePageState extends State<CuisineRecipePage> {
  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  String _search = '';
  bool _loading = false;

  final Map<String, String> localRecipeImages = {
    "Butter Chicken": "assets/images/butter-chicken.jpg",
    "Paneer Tikka": "assets/images/paneer-tikka.png",
    "Sushi Roll": "assets/images/sushi.jpg",
  };

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    setState(() => _loading = true);

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .get();

      final recipesData = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter by cuisine if needed
      final cuisineFiltered = widget.cuisineName == null
          ? recipesData
          : recipesData
          .where((recipe) =>
      (recipe['cuisine'] ?? '').toString().toLowerCase() ==
          widget.cuisineName!.toLowerCase())
          .toList();

      setState(() {
        _allRecipes = cuisineFiltered;
        _filteredRecipes = cuisineFiltered;
      });
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      setState(() {
        _allRecipes = [];
        _filteredRecipes = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterRecipes(String query) {
    setState(() {
      _search = query;
      _filteredRecipes = _allRecipes
          .where((recipe) => (recipe['title'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearchPage = widget.cuisineName == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSearchPage ? 'Search Recipes' : '${widget.cuisineName} Recipes'),
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
                hintText: isSearchPage
                    ? 'Search recipes...'
                    : 'Search ${widget.cuisineName} recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _filterRecipes('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterRecipes,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
                ? const Center(child: Text("No recipes found."))
                : ListView.builder(
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                final String title = recipe['title'] ?? 'No Title';
                final String? imageName = recipe['imageName'];
                final String assetPath = localRecipeImages[title] ??
                    (imageName != null
                        ? 'assets/images/$imageName'
                        : 'assets/default.jpg');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                    leading: Image.asset(
                      assetPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(title),
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
