import 'package:flutter/material.dart';

class SideNavigationDrawer extends StatelessWidget {
  const SideNavigationDrawer({super.key});

  static const Color deepOrange = Color(0xFFFF5722);

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: deepOrange),
              title: const Text("English"),
              onTap: () {
                Navigator.pop(context);
                // Set language to English here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Language set to English")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: deepOrange),
              title: const Text("বাংলা (Bangla)"),
              onTap: () {
                Navigator.pop(context);
                // Set language to Bangla here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ভাষা বাংলা সেট হয়েছে")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: deepOrange),
              title: const Text("हिन्दी (Hindi)"),
              onTap: () {
                Navigator.pop(context);
                // Set language to Hindi here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("भाषा हिन्दी सेट की गई")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: deepOrange,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Platr's Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Language Option
          ListTile(
            leading: const Icon(Icons.language, color: deepOrange),
            title: const Text('Language (Translate)'),
            onTap: () {
              Navigator.pop(context);
              _showLanguageDialog(context);
            },
          ),

          // Main Navigation
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: deepOrange),
                  title: const Text('View Profile'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: deepOrange),
                  title: const Text('Notifications'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark, color: deepOrange),
                  title: const Text('View Saved Items'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: deepOrange),
                  title: const Text('View Personal Recipes'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: deepOrange),
                  title: const Text('Settings'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: deepOrange),
                  title: const Text('Privacy Policy'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: deepOrange),
                  title: const Text('Logout'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Bottom Gradient Decoration
          Container(
            height: 60,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33FF5722), // 20%
                  Color(0x22FF5722), // 13%
                  Color(0x11FF5722), // 7%
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
