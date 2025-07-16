import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const List<Map<String, String>> teamMembers = [
    {
      "name": "Anika Sanzida Upoma",
      "roll": "02",
      "image": "assets/profiles/anika.jpeg",
      "github": "https://github.com/bluerabbit31",
      "role": "Executive Member",
      "bio": "Handles each recipe, profiles of every user and maintains privacy policy."
    },
    {
      "name": "Suraya Jannat Mim",
      "roll": "17",
      "image": "assets/profiles/mim.jpeg",
      "github": "https://github.com/Mim1726",
      "role": "Executive Member",
      "bio": "Designs user-centric interfaces and ensures the app is intuitive and appealing."
    },
    {
      "name": "Ishrat Jahan Mim",
      "roll": "52",
      "image": "assets/profiles/ishrat.jpeg",
      "github": "https://github.com/Ishrat001",
      "role": "Executive Member",
      "bio": "Focused on backend logic and user database integration. Handles Q&A of users."
    },
    {
      "name": "Tasmia Sultana Sumi",
      "roll": "54",
      "image": "assets/profiles/sumi.jpeg",
      "github": "https://github.com/HIDDENtas12345",
      "role": "Executive Member",
      "bio": "Handles each recipe, manages app settings and add images."
    },
  ];

  void _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) throw 'Could not launch $url';
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch GitHub profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Solid white color
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 40),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/logo5.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Team DU_CodeBots",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Crafting Innovation, Serving Excellence!",
                  style: TextStyle(color: Colors.grey[800]),
                ),
                const SizedBox(height: 20),

                // Team Members
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                AssetImage(member['image'] ?? ''),
                                onBackgroundImageError:
                                    (_, __) => const Icon(Icons.person),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Roll: ${member['roll']}"),
                                    Text(
                                      member['role'] ?? '',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/profiles/git.jpeg',
                                  height: 24,
                                ),
                                onPressed: () =>
                                    _launchURL(context, member['github'] ?? ''),
                                tooltip: "Open GitHub Profile",
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            member['bio'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
