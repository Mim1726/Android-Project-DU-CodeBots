// recipe_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details.dart';
import 'side_navigation.dart';

class CuisineRecipePage extends StatefulWidget {
  final String? cuisineName;

  const CuisineRecipePage({super.key, this.cuisineName});

  const CuisineRecipePage.search({super.key}) : cuisineName = null;

  @override
  State<CuisineRecipePage> createState() => _CuisineRecipePageState();
}

class _CuisineRecipePageState extends State<CuisineRecipePage> {
  // ---------- STATE ----------
  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  String _search = '';
  bool _loading = false;
  String? _selectedMealType = 'All'; // ‘All’ selected by default

  final Map<String, String> localRecipeImages = {
    "Butter Chicken": "assets/images/butter-chicken.jpg",
    "Paneer Tikka": "assets/images/paneer-tikka.png",
    "Sushi Roll": "assets/images/sushi.jpg",
  };

  // Only real meal types here; ‘All’ rendered separately
  final List<String> mealTypes = ['Breakfast', 'Snacks', 'Dessert', 'Lunch', 'Dinner'];

  // ---------- INIT ----------
  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  // ---------- FETCH RECIPES ----------
  Future<void> fetchRecipes() async {
    setState(() => _loading = true);

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('recipes').get();

      final recipesData = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

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

  // ---------- FILTERS ----------
  void _filterRecipes(String query) {
    setState(() {
      _search = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final titleMatch = (recipe['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_search.toLowerCase());

        final mealMatch = _selectedMealType == null ||
            _selectedMealType == 'All' ||
            (recipe['mealType'] ?? '')
                .toString()
                .toLowerCase()
                .trim() ==
                _selectedMealType!.toLowerCase().trim();

        return titleMatch && mealMatch;
      }).toList();
    });
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final isSearchPage = widget.cuisineName == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSearchPage ? 'Search Recipes' : '${widget.cuisineName} Recipes',
        ),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Column(
            children: [
              // ---------- SEARCH BAR ----------
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    hintText: isSearchPage
                        ? 'Search recipes...'
                        : 'Search ${widget.cuisineName} recipes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _filterRecipes(''),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterRecipes,
                ),
              ),

              // ---------- MEAL-TYPE & ALL FILTER CHIPS ----------
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // --- ‘All’ CHIP ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedMealType == 'All',
                        selectedColor: Colors.deepOrange,
                        labelStyle: TextStyle(
                          color: _selectedMealType == 'All'
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedMealType = 'All';
                            _applyFilters();
                          });
                        },
                        backgroundColor: Colors.white,
                      ),
                    ),
                    // --- OTHER MEAL-TYPE CHIPS ---
                    ...mealTypes.map((type) {
                      final isSelected = type == _selectedMealType;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: Colors.deepOrange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedMealType = selected ? type : 'All';
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // ---------- RECIPES LIST ----------
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecipes.isEmpty
                    ? const Center(
                  child: Text(
                    "No recipes found.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _filteredRecipes[index];
                    final String title = recipe['title'] ?? 'No Title';
                    final String? imageName = recipe['imageName'];
                    final String assetPath = localRecipeImages[title] ??
                        (imageName != null
                            ? 'assets/images/$imageName'
                            : 'assets/images/default2.jpeg');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailPage(recipe: recipe),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              assetPath,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (recipe['duration'] != null)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${recipe['duration']} mins',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

