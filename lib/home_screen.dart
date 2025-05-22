import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Cleaner constructor using super.key
  const HomeScreen({super.key});

  // Dummy cuisine list
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
        title: const Text(
          'Platr',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
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

          // List of Cuisines
          Expanded(
            child: ListView.builder(
              itemCount: cuisines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    cuisines[index]['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    cuisines[index]['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to list of recipes for this cuisine
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Home selected
        onTap: (index) {
          // TODO: Handle bottom nav tap
        },
      ),
    );
  }
}