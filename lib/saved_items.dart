// saved_items.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_details.dart';
import 'side_navigation.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  // ---------- STATE ----------
  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  String _search = '';
  String? _selectedMealType = 'All'; // ‘All’ selected by default
  bool _loading = false;

  // Only real meal types here; ‘All’ is rendered separately
  final List<String> mealTypes = [
    'Breakfast',
    'Snacks',
    'Dessert',
    'Lunch',
    'Dinner',
  ];

  // ---------- INIT ----------
  @override
  void initState() {
    super.initState();
    fetchSavedRecipes();
  }

  // ---------- LOAD SAVED RECIPES ----------
  Future<void> fetchSavedRecipes() async {
    setState(() => _loading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      setState(() {
        _allRecipes = [];
        _filteredRecipes = [];
        _loading = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('saved_recipes')
          .where('userId', isEqualTo: userId)
          .get();

      final recipesData = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _allRecipes = recipesData;
        _filteredRecipes = recipesData;
      });
    } catch (e) {
      debugPrint("Error loading saved recipes: $e");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepOrange,
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
              'assets/screen_images/screen5.jpg',
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
                    hintText: 'Search saved recipes...',
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

              // ---------- FILTER CHIPS ----------
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
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedMealType = 'All';
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    // --- MEAL TYPE CHIPS ---
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
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedMealType =
                              selected ? type : 'All';
                              _applyFilters();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // ---------- LIST ----------
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecipes.isEmpty
                    ? Center(
                  child: Text(
                    _search.isEmpty
                        ? 'No saved recipes found.'
                        : 'No results for "$_search".',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _filteredRecipes[index];
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          recipe['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                            recipe['mealType'] ?? 'No Meal Type'),
                        leading: recipe['imageName'] != null
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/${recipe['imageName']}',
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image),
                          ),
                        )
                            : const Icon(Icons.image),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(
                                  recipe: recipe),
                            ),
                          );
                        },
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
