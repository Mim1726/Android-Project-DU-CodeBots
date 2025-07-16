// lib/personal_recipes.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_approval_page.dart';
import 'personal_recipe_details.dart';
import 'side_navigation.dart';

// ---------------------------------------------------------------------------
// UPDATE – duplicate the developer e‑mails so this file can know who is a dev.
// If you later centralise them, remove this list and import the shared one.
// ---------------------------------------------------------------------------
const devEmails = [
  'ishratjahan7711@gmail.com',
  'sumitasmia515@gmail.com',
  'mimrobo1726@gmail.com',
  'anikasanzida31593@gmail.com',
];

class PersonalRecipesPage extends StatefulWidget {
  const PersonalRecipesPage({super.key});

  @override
  State<PersonalRecipesPage> createState() => _PersonalRecipesPageState();
}

class _PersonalRecipesPageState extends State<PersonalRecipesPage> {
  // ---------------- state ----------------
  List<QueryDocumentSnapshot> _all = [];
  List<QueryDocumentSnapshot> _view = [];
  bool   _loading = true;
  String _search  = '';
  String _selectedMealType = 'All';                     // UPDATE default

  final mealTypes = const [
    'All', 'Breakfast', 'Snacks', 'Dessert', 'Lunch', 'Dinner'
  ];

  // ---------------- init -----------------
  @override
  void initState() {
    super.initState();
    _listenMyRecipes();
  }

  void _listenMyRecipes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('pending_recipes')
        .where('authorId', isEqualTo: uid)              // only my recipes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      setState(() {
        _all     = snap.docs;
        _applyFilters();
        _loading = false;
      });
    }, onError: (_) => setState(() => _loading = false));
  }

  // ---------------- filtering -------------
  void _applyFilters() {
    setState(() {
      _view = _all.where((doc) {
        final d         = doc.data()! as Map<String, dynamic>;
        final title     = (d['title']    ?? '').toString();
        final mealType  = (d['mealType'] ?? '').toString();
        final okTitle   = title.toLowerCase().contains(_search.toLowerCase());
        final okMeal    = _selectedMealType == 'All'
            || mealType.toLowerCase() == _selectedMealType.toLowerCase();
        return okTitle && okMeal;
      }).toList();
    });
  }

  // ---------------- build -----------------
  @override
  Widget build(BuildContext context) {
    final user  = FirebaseAuth.instance.currentUser;
    final isDev = devEmails.contains(user?.email);      // UPDATE

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recipes'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepOrange,
        actions: [
          if (isDev)                                     // UPDATE
            IconButton(
              tooltip: 'Pending approvals',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () =>
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminApprovalPage())),
            ),
          Builder(builder: (ctx) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          )),
        ],
      ),
      endDrawer: const SideNavigationDrawer(),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/screen_images/screen6.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          Column(
            children: [
              // ---------- search ----------
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    hintText: 'Search your recipes…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search = '';
                        _applyFilters();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (q) {
                    _search = q;
                    _applyFilters();
                  },
                ),
              ),

              // ---------- meal chips ----------
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: mealTypes.length,
                  itemBuilder: (_, i) {
                    final t    = mealTypes[i];
                    final sel  = t == _selectedMealType;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: sel,
                        selectedColor: Colors.deepOrange,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                            color: sel ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold),
                        onSelected: (_) {
                          setState(() => _selectedMealType = t);
                          _applyFilters();
                        },
                      ),
                    );
                  },
                ),
              ),

              // ---------- list ----------
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _view.isEmpty
                    ? const Center(
                  child: Text('No recipes yet',
                      style: TextStyle(color: Colors.white)),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _view.length,
                  itemBuilder: (_, i) {
                    final doc      = _view[i];
                    final d        = doc.data()! as Map<String, dynamic>;
                    final imgUrl   = (d['imageUrl'] ?? '') as String;
                    final pending  = !(d['approved'] ?? false);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: ListTile(
                        leading: imgUrl.isNotEmpty
                            ? Image.network(imgUrl,
                            width: 60, fit: BoxFit.cover)
                            : Image.asset('assets/images/default2.jpeg',
                            width: 60, fit: BoxFit.cover),
                        title: Text(d['title'] ?? 'No Title'),
                        subtitle: Text(
                            '${d['cuisine'] ?? ''} – ${d['description'] ?? ''}'),
                        trailing: pending
                            ? const Chip(
                          label: Text('Pending',
                              style:
                              TextStyle(color: Colors.white)),
                          backgroundColor: Colors.orange,
                        )
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PersonalRecipeDetailsPage(recipe: doc)),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalRecipeDetailsPage()),
        ),
        label: const Text('Add More'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF5722),
      ),
    );
  }
}
