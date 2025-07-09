import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'side_navigation.dart';
import 'spice_calculator.dart';
import 'chat_page.dart';
import 'signup_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? toggleTheme;

  const RecipeDetailPage({super.key, required this.recipe, this.toggleTheme});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  int likeCount = 0;
  List<String> comments = [];
  bool isBookmarked = false;
  bool _isReadingAloud = false;

  static const Color deepOrange = Color(0xFFFF5722);
  //static const Color deepOrange = Color(0xFFFF7043);
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _stopTTS() {
    _flutterTts.stop();
    _isReadingAloud = false;
  }

  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  void _requireLoginMessage() {
    _stopTTS();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⚠️ You haven't signed up yet"),
        content: const Text("Please sign up or log in to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              );
            },
            child: const Text("Sign Up"),
          ),
        ],
      ),
    );
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

  void _readStepsAloud(List<String> instructions) async {
    if (_isReadingAloud) return;
    _isReadingAloud = true;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    for (int i = 0; i < instructions.length; i++) {
      if (!_isReadingAloud) break;
      String step = "Step ${i + 1}. ${instructions[i]}";
      await _flutterTts.speak(step);
      await Future.delayed(const Duration(seconds: 3));
    }

    _isReadingAloud = false;
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) _stopTTS();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    List<String> ingredients = [];
    var rawIngredients = recipe['ingredients'];
    if (rawIngredients is List) {
      ingredients = rawIngredients.map((e) => e.toString()).toList();
    } else if (rawIngredients is String) {
      ingredients = rawIngredients.split(',').map((e) => e.trim()).toList();
    }

    List<String> amounts = [];
    var rawAmounts = recipe['amount'];
    if (rawAmounts is List) {
      amounts = rawAmounts.map((e) => e.toString()).toList();
    } else if (rawAmounts is String) {
      amounts = rawAmounts.split(',').map((e) => e.trim()).toList();
    }

    final List<String> instructions = (recipe['instructions'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    final String? youtubeLink = recipe['youtubeLink'];
    final String? imageName = recipe['imageName'];

    return PopScope(
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            recipe['title'] ?? 'Recipe',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: deepOrange,
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
            Container(
              color: const Color(0xFFF5F0EB),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
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
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/default2.jpeg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(
                        'assets/images/default2.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ingredients:',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < ingredients.length; i++)
                      Text('${ingredients[i]} = ${i < amounts.length ? amounts[i] : 'N/A'}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _stopTTS();
                        if (!_isUserLoggedIn()) return _requireLoginMessage();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpiceCalculatorPage(
                              ingredients: ingredients,
                              amounts: amounts,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: deepOrange),
                      child: const Text('Calculate Ingredient Amounts', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...instructions.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text('$index. $step'),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 70,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _stopTTS();
                      if (!_isUserLoggedIn()) return _requireLoginMessage();
                      setState(() => likeCount++);
                      _iconController.forward().then((_) => _iconController.reverse());
                    },
                    child: ScaleTransition(
                      scale: _iconController,
                      child: const Icon(Icons.thumb_up, color: deepOrange, size: 32),
                    ),
                  ),
                  Text('$likeCount'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _stopTTS();
                      if (!_isUserLoggedIn()) return _requireLoginMessage();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            recipeId: recipe['title'],
                            recipeTitle: recipe['title'],
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.comment, color: deepOrange, size: 32),
                  ),
                  Text('${comments.length}'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _stopTTS();
                      if (!_isUserLoggedIn()) return _requireLoginMessage();
                      final title = recipe['title'];
                      final message = youtubeLink != null
                          ? 'Check out this recipe: $title\n$youtubeLink'
                          : 'Check out this recipe: $title';
                      Share.share(message);
                    },
                    child: const Icon(Icons.share, color: deepOrange, size: 32),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      _stopTTS();
                      if (!_isUserLoggedIn()) return _requireLoginMessage();
                      setState(() => isBookmarked = !isBookmarked);

                      if (isBookmarked) {
                        try {
                          final existing = await FirebaseFirestore.instance
                              .collection('saved_recipes')
                              .where('title', isEqualTo: widget.recipe['title'])
                              .get();

                          if (existing.docs.isEmpty) {
                            final recipeToSave = {
                              'title': widget.recipe['title'],
                              'ingredients': widget.recipe['ingredients'],
                              'instructions': widget.recipe['instructions'],
                              'youtubeLink': widget.recipe['youtubeLink'],
                              'imageName': widget.recipe['imageName'],
                              'duration': widget.recipe['duration'] ?? '',
                              'timestamp': FieldValue.serverTimestamp(),
                            };

                            await FirebaseFirestore.instance
                                .collection('saved_recipes')
                                .add(recipeToSave);

                            _showToast('✅ Recipe saved!');
                          } else {
                            _showToast('⚠️ Recipe already saved!');
                          }
                        } catch (e) {
                          _showToast('❌ Failed to save recipe');
                        }
                      }
                    },
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: deepOrange,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
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
                          if (!_isUserLoggedIn()) return _requireLoginMessage();
                          if (youtubeLink != null) _launchYouTube(youtubeLink);
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Watch on YouTube',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      color: const Color(0xFFF5F0EB),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _stopTTS();
                          if (!_isUserLoggedIn()) return _requireLoginMessage();
                          _readStepsAloud(instructions);
                        },
                        icon: const Icon(Icons.volume_up, color: Colors.white),
                        label: const Text(
                          'Hear steps',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            ),
          ],
        ),
      ),
    );
  }
}
