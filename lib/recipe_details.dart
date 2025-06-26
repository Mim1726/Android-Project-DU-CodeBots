import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'side_navigation.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  int likeCount = 0;
  List<String> comments = [];

  static const Color deepOrange = Color(0xFFFF5722);

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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Could not open YouTube link');
    }
  }

  void _readStepsAloud(List<String> instructions) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    for (int i = 0; i < instructions.length; i++) {
      String step = "Step ${i + 1}. ${instructions[i]}";
      await _flutterTts.speak(step);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final List<String> ingredients = (recipe['ingredients'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    final List<String> instructions = (recipe['instructions'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    final String? youtubeLink = recipe['youtubeLink'];
    final String? imageName = recipe['imageName'];

    return Scaffold(
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
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(ingredients.join(', ')),
                  const SizedBox(height: 20),
                  Text(
                    'Instructions:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
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

          // Floating buttons
          Positioned(
            bottom: 70,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _iconController.forward().then((_) => _iconController.reverse());
                    setState(() => likeCount++);
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
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Comment'),
                        content: TextField(
                          onSubmitted: (text) {
                            setState(() => comments.add(text));
                            Navigator.pop(context);
                          },
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
                  onTap: () => _showSnack('🔖 Recipe saved!'),
                  child: const Icon(Icons.bookmark_border, color: deepOrange, size: 32),
                ),
              ],
            ),
          ),

          // Bottom bar
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                      onPressed: () => _readStepsAloud(instructions),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
