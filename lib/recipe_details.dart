// recipe_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'side_navigation.dart';
import 'spice_calculator.dart';
import 'review.dart';
import 'q&a_page.dart';           // ChatScreen (user)
import 'developers_question_page.dart'; // DChatScreen (developer)
import 'recipe_audio_guide_page.dart';  // ✅ audio guide page

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<String>? customAmounts;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.customAmounts,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  static const Color deepOrange = Color(0xFFFF5722);
  static const String appShareUrl =
      'https://play.google.com/store/apps/details?id=com.yourcompany.yourapp';

  final FlutterTts _flutterTts = FlutterTts();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLiked = false;
  bool isBookmarked = false;
  bool _isReadingAloud = false;
  int likeCount = 0;

  late AnimationController _iconController;
  String? userId;

  static const devEmails = [
    'ishratjahan7711@gmail.com',
    'sumitasmia515@gmail.com',
    'mimrobo1726@gmail.com',
    'anikasanzida31593@gmail.com',
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.3,
    );

    userId = FirebaseAuth.instance.currentUser?.uid;
    _checkIfBookmarked();
    _loadLikesStatus();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkIfBookmarked() async {
    if (userId == null) return;
    final docId = '${widget.recipe['title']}_$userId';
    final doc = await _firestore.collection('saved_recipes').doc(docId).get();
    if (doc.exists) {
      setState(() => isBookmarked = true);
    }
  }

  Future<void> _loadLikesStatus() async {
    if (userId == null) return;
    final doc = await _firestore
        .collection('recipes')
        .doc(widget.recipe['title'])
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      setState(() {
        isLiked = likedBy.contains(userId);
        likeCount = data['likes'] ?? 0;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (userId == null) {
      _showToast('Please login to like.');
      return;
    }

    final recipeDocRef =
    _firestore.collection('recipes').doc(widget.recipe['title']);

    await _firestore.runTransaction((transaction) async {
      final freshSnap = await transaction.get(recipeDocRef);
      if (!freshSnap.exists) return;

      final freshData = freshSnap.data()!;
      final likedBy = List<String>.from(freshData['likedBy'] ?? []);
      int likes = freshData['likes'] ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        likes = (likes > 0) ? likes - 1 : 0;
        setState(() {
          isLiked = false;
          likeCount = likes;
        });
      } else {
        likedBy.add(userId!);
        likes += 1;
        setState(() {
          isLiked = true;
          likeCount = likes;
        });
      }

      transaction.update(recipeDocRef, {
        'likedBy': likedBy,
        'likes': likes,
      });
    });
  }

  void _stopTTS() {
    _flutterTts.stop();
    _isReadingAloud = false;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _launchYouTube(String url) async {
    try {
      if (!url.startsWith('http')) url = 'https://$url';
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showToast('❌ Could not launch video.');
      }
    } catch (e) {
      _showToast('❌ Error opening link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    List<String> ingredients = [];
    final rawIngredients = recipe['ingredients'];
    if (rawIngredients is List) {
      ingredients = rawIngredients.map((e) => e.toString()).toList();
    } else if (rawIngredients is String) {
      ingredients = rawIngredients.split(',').map((e) => e.trim()).toList();
    }

    List<String> amounts = [];
    final rawAmounts = recipe['amount'];
    if (rawAmounts != null) {
      if (rawAmounts is List) {
        amounts = rawAmounts.map((e) => e.toString()).toList();
      } else if (rawAmounts is String) {
        amounts = rawAmounts.split(',').map((e) => e.trim()).toList();
      }
    }

    if (widget.customAmounts != null &&
        widget.customAmounts!.length == ingredients.length) {
      amounts = widget.customAmounts!;
    }

    final instructions = (recipe['instructions'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    final String? youtubeLink = recipe['youtubeLink'];
    final String? imageName = recipe['imageName'];

    return WillPopScope(
      onWillPop: () async {
        _stopTTS();
        return true;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context, recipe['title'] ?? 'Recipe'),
            endDrawer: const SideNavigationDrawer(),
            body: Stack(
              children: [
                _buildScrollableContent(context, recipe, ingredients, amounts,
                    instructions, imageName),
                _buildFloatingButtons(recipe, youtubeLink),
                _buildQAButton(recipe),
                _buildBottomBar(instructions, imageName, youtubeLink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: deepOrange),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: deepOrange,
        ),
      ),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert, color: deepOrange),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent(
      BuildContext context,
      Map<String, dynamic> recipe,
      List<String> ingredients,
      List<String> amounts,
      List<String> instructions,
      String? imageName,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageName != null
                ? Image.asset(
              'assets/images/$imageName',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset('assets/images/default2.jpeg'),
            )
                : Image.asset('assets/images/default2.jpeg'),
          ),
          const SizedBox(height: 20),
          Text('Ingredients:',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: deepOrange,
              )),
          const SizedBox(height: 8),
          for (int i = 0; i < ingredients.length; i++)
            Text(
              '${ingredients[i]} = ${i < amounts.length ? amounts[i] : 'N/A'}',
              style: const TextStyle(color: Colors.black),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _stopTTS();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpiceCalculatorPage(
                    ingredients: ingredients,
                    amounts: amounts,
                    onCalculated: (List<String> newAmounts) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(
                            recipe: recipe,
                            customAmounts: newAmounts,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: deepOrange),
            child: const Text('Calculate Ingredient Amounts',
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Text('Instructions:',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: deepOrange,
              )),
          const SizedBox(height: 8),
          ...instructions.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '$index. $step',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(
      Map<String, dynamic> recipe, String? youtubeLink) {
    return Positioned(
      bottom: 70,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _stopTTS();
              _toggleLike();
              _iconController.forward().then((_) => _iconController.reverse());
            },
            child: ScaleTransition(
              scale: _iconController,
              child: Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: deepOrange,
                size: 32,
              ),
            ),
          ),
          Text(
            '$likeCount',
            style: const TextStyle(
              color: deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              _stopTTS();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => chatScreen(
                    recipeId: recipe['title'],
                    recipeTitle: recipe['title'],
                  ),
                ),
              );
            },
            child: const Icon(Icons.comment, color: deepOrange, size: 32),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              _stopTTS();
              final title = recipe['title'];
              String message =
                  'Check out this recipe "$title" in our Recipe app:\n$appShareUrl';
              if (youtubeLink != null && youtubeLink.isNotEmpty) {
                message += '\n\nWatch the video tutorial: $youtubeLink';
              }
              Share.share(message);
            },
            child: const Icon(Icons.share, color: deepOrange, size: 32),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              _stopTTS();
              if (userId == null) {
                _showToast('Please login to save recipes.');
                return;
              }
              final docId = '${recipe['title']}_$userId';
              final savedRef =
              _firestore.collection('saved_recipes').doc(docId);

              if (isBookmarked) {
                await savedRef.delete();
                _showToast('❌ Recipe removed from saved items');
              } else {
                final recipeToSave = {
                  'title': recipe['title'],
                  'ingredients': recipe['ingredients'],
                  'amount': recipe['amount'],
                  'instructions': recipe['instructions'],
                  'youtubeLink': recipe['youtubeLink'],
                  'imageName': recipe['imageName'],
                  'duration': recipe['duration'] ?? '',
                  'mealType': recipe['mealType'] ?? '',
                  'userId': userId,
                  'timestamp': FieldValue.serverTimestamp(),
                };
                await savedRef.set(recipeToSave);
                _showToast('✅ Recipe saved!');
              }

              setState(() => isBookmarked = !isBookmarked);
            },
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: deepOrange,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQAButton(Map<String, dynamic> recipe) {
    return Positioned(
      bottom: 65,
      left: 12,
      child: GestureDetector(
        onTap: () {
          _stopTTS();
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            _showToast("Please log in to ask a question.");
            return;
          }

          final isDev = devEmails.contains(user.email);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => isDev
                  ? DChatScreen(recipeId: recipe['title'])
                  : ChatScreen(recipeId: recipe['title']),
            ),
          );
        },
        child: const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.question_answer, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<String> instructions, String? imageName,
      String? youtubeLink) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: deepOrange,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _stopTTS();
                  if (youtubeLink != null) {
                    _launchYouTube(youtubeLink);
                  }
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Watch on YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepOrange,
                  elevation: 0,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _stopTTS();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeAudioGuidePage(
                        instructions: instructions,
                        imageAsset: imageName != null
                            ? 'assets/images/$imageName'
                            : 'assets/images/default2.jpeg',
                        recipeName: widget.recipe['title'] ?? 'Recipe',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: const Text(
                  'Hear steps',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepOrange,
                  elevation: 0,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
