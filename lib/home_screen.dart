import 'package:flutter/material.dart';
import 'recipe_page.dart';
import 'side_navigation.dart'; // 🔥 Import the drawer

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> cuisines = const [
    {'name': 'Indian', 'emoji': '🍲'},
    {'name': 'Italian', 'emoji': '🍝'},
    {'name': 'Japanese', 'emoji': '🍣'},
    {'name': 'Mexican', 'emoji': '🌮'},
    {'name': 'French', 'emoji': '🥐'},
    {'name': 'Bangladeshi', 'emoji': '🍛'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platr', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const SideNavigationDrawer(), // 🔥 Attach drawer
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                // TODO: Navigate to Search Page
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cuisines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(cuisines[index]['emoji']!, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    cuisines[index]['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CuisineRecipePage(
                          cuisineName: cuisines[index]['name']!,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmarks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: Handle bottom nav tap
        },
      ),
    );
  }
}
