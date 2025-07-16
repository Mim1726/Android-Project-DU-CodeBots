// home_screen.dart
import 'package:flutter/material.dart';
import 'recipe_page.dart';
import 'side_navigation.dart';
import 'search_page.dart';
import 'profile_page.dart'; // ✅ import profile page

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> cuisines = const [
    {'name': 'Indian',      'emoji': '🍲', 'image': 'assets/images/paneer-tikka.png'},
    {'name': 'Italian',     'emoji': '🍝', 'image': 'assets/images/spaghetti-carbonara.jpg'},
    {'name': 'Japanese',    'emoji': '🍣', 'image': 'assets/images/sushi.jpg'},
    {'name': 'Mexican',     'emoji': '🌮', 'image': 'assets/images/tacos_al_pastor.jpg'},
    {'name': 'French',      'emoji': '🥐', 'image': 'assets/images/french-toast.jpg'},
    {'name': 'Bangladeshi', 'emoji': '🍛', 'image': 'assets/images/panta_ilish.jpg'},
    {'name': 'Thai',        'emoji': '🍜', 'image': 'assets/images/pad_thai.jpg'},
    {'name': 'Chinese',     'emoji': '🥡', 'image': 'assets/images/hotpot.jpg'},
    {'name': 'American',    'emoji': '🍔', 'image': 'assets/images/burger.jpg'},
    {'name': 'Turkish',     'emoji': '🍢', 'image': 'assets/images/kunefe.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  const BorderSide(color: Colors.deepOrange, width: 2),
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),

        ),
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const SideNavigationDrawer(),
      body: Stack(
        children: [
          // 🌙 Background image + dark overlay (no blur)
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4), // adjust 0.4 → lighter/darker
            ),
          ),

          // 📜 Main content
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchPage()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cuisines.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final cuisine = cuisines[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CuisineRecipePage(cuisineName: cuisine['name']!),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white70,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        cuisine['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        color: const Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: Text(
                                  '${cuisine['emoji']} ${cuisine['name']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
