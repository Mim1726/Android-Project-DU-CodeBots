// ratings.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingsPage extends StatefulWidget {
  final String recipeTitle;

  const RatingsPage({super.key, required this.recipeTitle});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  // ---------- STATE ----------
  int _selectedRating = 0;   // user’s chosen stars
  bool _hasRated = false;    // disables buttons after rating

  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------- INITIAL LOAD ----------
  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    if (userId == null) return;
    final snap =
    await _firestore.collection('recipes').doc(widget.recipeTitle).get();

    final data = snap.data() as Map<String, dynamic>? ?? {};
    final ratings = data['ratings'] as Map<String, dynamic>? ?? {};

    if (ratings.containsKey(userId)) {
      setState(() {
        _selectedRating = ratings[userId] as int;
        _hasRated = true;
      });
    }
  }

  // ---------- FIRESTORE WRITE ----------
  Future<void> _submitRating(int stars) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to rate.")),
      );
      return;
    }

    await _firestore.collection('recipes').doc(widget.recipeTitle).set({
      'ratings': {userId!: stars}
    }, SetOptions(merge: true));
  }

  // ---------- STAR WIDGET ----------
  Widget _buildStarRow(int displayRating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
            (i) => IconButton(
          icon: Icon(
            Icons.star,
            size: 36,
            color: i < displayRating ? Colors.deepOrange : Colors.grey,
          ),
          onPressed: _hasRated
              ? null
              : () async {
            setState(() {
              _selectedRating = i + 1;
              _hasRated = true; // lock immediately
            });
            await _submitRating(i + 1);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Thanks for rating!")),
              );
            }
          },
        ),
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate: ${widget.recipeTitle}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('recipes')
            .doc(widget.recipeTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // ----- ratings data from Firestore -----
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final ratings = data['ratings'] as Map<String, dynamic>? ?? {};

          final values = ratings.values.map((e) => e as int).toList();
          final averageRating =
          values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0;
          final totalRatings = values.length;

          // Use state value if user has just rated; otherwise DB value
          final userRating =
          userId != null && ratings.containsKey(userId) ? ratings[userId] as int : 0;
          final displayRating = _hasRated ? _selectedRating : userRating;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How would you rate this recipe?',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _buildStarRow(displayRating),
                  const SizedBox(height: 20),

                  // ---------- RATING SUMMARY ALWAYS VISIBLE ----------
                  if (totalRatings == 0) ...[
                    const Text(
                      'No ratings yet – be the first!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ] else ...[
                    Text(
                      '⭐ Average Rating: ${averageRating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      '📊 Based on $totalRatings vote${totalRatings > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
