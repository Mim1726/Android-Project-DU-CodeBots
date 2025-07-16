import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'personal_recipes.dart';
import 'saved_items.dart';
import 'about_us.dart';
import 'privacy_policy_page.dart';
import 'profile_page.dart';
import 'settings_page.dart'; // 👈 NEW
import 'login_page.dart';

class SideNavigationDrawer extends StatelessWidget {
  const SideNavigationDrawer({super.key});

  static const Color deepOrange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/screen_images/screen3.jpg', fit: BoxFit.cover),
          Column(
            children: [
              const SizedBox(height: 50),
              _header(),
              //const Divider(thickness: 1),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem(Icons.person, 'View Profile', context,
                        navigateTo: const ProfilePage()),
                    _drawerItem(
                        Icons.notifications, 'Notifications', context),
                    _drawerItem(Icons.bookmark, 'View Saved Items', context,
                        navigateTo: const SavedItemsPage()),
                    _drawerItem(Icons.receipt_long, 'View Personal Recipes',
                        context,
                        navigateTo: const PersonalRecipesPage()),
                    _drawerItem(Icons.info_outline, 'About Us', context,
                        navigateTo: const AboutUsPage()),

                    // SETTINGS now opens SettingsPage
                    _drawerItem(Icons.settings, 'Settings', context,
                        navigateTo: SettingsPage(
                          isDarkMode: false,      // TODO: replace with real value
                          fontSize: 16,           // TODO: replace with real value
                          language: 'English',    // TODO: replace with real value
                          onThemeChanged: (_) {},     // TODO: connect to state
                          onFontSizeChanged: (_) {},  // TODO: connect to state
                          onLanguageChanged: (_) {},  // TODO: connect to state
                        )),

                    _drawerItem(Icons.privacy_tip, 'Privacy Policy', context,
                        navigateTo: const PrivacyPolicyPage()),
                    //const Divider(thickness: 1, height: 0),

                    // 🔒 Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: deepOrange),
                      title: const Text('Logout',
                          style: TextStyle(color: Colors.black)),
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                                'Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                                (_) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Helpers =====
  Widget _header() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        left: BorderSide(color: deepOrange, width: 5),
      ),
    ),
    child: const Text(
      "Platr's Menu",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: deepOrange,
      ),
    ),
  );

  Widget _drawerItem(IconData icon, String title, BuildContext context,
      {Widget? navigateTo}) =>
      ListTile(
        leading: Icon(icon, color: deepOrange),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context); // close drawer
          if (navigateTo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => navigateTo),
            );
          }
        },
      );
}
