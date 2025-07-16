import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool isBangla = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          isBangla ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isBangla = !isBangla),
            child: Text(
              isBangla ? 'English' : 'বাংলা',
              style: const TextStyle(
                color: Colors.deepOrangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screen_images/screen8.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionCard(
                  title: isBangla ? '১. পরিচিতি' : '1. Introduction',
                  body: isBangla
                      ? 'Platr একটি ফুড রেসিপি অ্যাপ যা ব্যবহারকারীদের বিভিন্ন রেসিপি খুঁজে বের করতে, সংরক্ষণ করতে এবং নিজেরা রেসিপি জমা দিতে সহায়তা করে। ব্যবহারকারীরা বিভিন্ন ধরনের রান্নার ভিডিও দেখতে পারে, নিজস্ব রেসিপি সাবমিট করতে পারে এবং ব্যক্তিগত পছন্দ অনুযায়ী কনটেন্ট পেতে পারে।\n\nএকটি উন্নত ও ব্যক্তিগতকৃত অভিজ্ঞতা দিতে আমরা কিছু তথ্য সংগ্রহ করি। এই গোপনীয়তা নীতিতে বর্ণনা করা হয়েছে কী তথ্য আমরা সংগ্রহ করি, কিভাবে তা ব্যবহার করি, এবং আপনি আপনার তথ্য ব্যবস্থাপনায় কী কী অধিকার রাখেন।'
                      : 'Welcome to Platr — your personalized food recipe companion. Platr is a mobile application designed to help users discover, save and cook a variety of recipes. Users can browse recipes from different cuisines, submit their own creations, add YouTube video links for cooking guidance and interact with food‑related content tailored to their preferences.\n\nTo deliver a smooth & personalized experience, we collect and use certain types of information. This Privacy Policy outlines what data we collect, how we use it, how we keep it safe and the choices you have in managing your personal information. By using Platr, you agree to the practices described in this policy.',
                ),
                SectionCard(
                  title: isBangla ? '২. আমরা যেসব তথ্য সংগ্রহ করি' : '2. Information We Collect',
                  body: isBangla
                      ? '- নাম ও ইমেইল (অ্যাকাউন্ট তৈরি করতে)\n- প্রোফাইল ছবি (ঐচ্ছিক)\n- ইউজার আইডি ও পাসওয়ার্ড\n- সংরক্ষিত, জমা দেওয়া বা দেখা রেসিপি\n- অ্যাপে করা প্রশ্ন\n- সংরক্ষণের পছন্দ\n- পছন্দের রন্ধন প্রকার\n- জমাকৃত রেসিপির ইউটিউব লিংক\n- রেসিপিতে যুক্ত ইউটিউব ভিডিও লিংক'
                      : '- Name and email for account creation\n- Profile picture (optional)\n- User ID and password for authentication\n- Recipes saved, submitted or viewed\n- Questions asked in the app\n- User preferences for saved recipes\n- User preferences for cuisine types\n- Optional YouTube links in submitted recipes\n- YouTube video links added to recipes',
                ),
                SectionCard(
                  title: isBangla ? '৩. আপনার ডেটা কীভাবে ব্যবহার করি' : '3. How We Use Your Data',
                  body: isBangla
                      ? 'আমরা আপনার তথ্য ব্যবহার করি:\n- পছন্দ অনুযায়ী রেসিপি ও কুইজিন দেখাতে\n- রেসিপি জমা ও পরিচালনা করতে (অ্যাডমিন অনুমোদনের মাধ্যমে)\n- আপনার প্রশ্নের উত্তর দিতে\n- অ্যাপের ফিচার ও রিকমেন্ডেশন উন্নত করতে'
                      : 'We use your information to:\n- Show personalized recipes and cuisine types\n- Let you submit and manage recipes (with admin approval)\n- Respond to your questions\n- Improve app features and recipe recommendations',
                ),
                SectionCard(
                  title: isBangla ? '৪. রেসিপি জমা ও পর্যবেক্ষণ' : '4. Recipe Submission & Moderation',
                  body: isBangla
                      ? 'ব্যবহারকারীরা উপকরণ, কুইজিন, নির্দেশনা, আনুমানিক সময়, ডিশ টাইপ, উপকরণের পরিমাণ, খাবারের ছবি ও ঐচ্ছিক ইউটিউব লিংকসহ রেসিপি জমা দিতে পারেন। জমা দেওয়া রেসিপিগুলো অ্যাডমিন দ্বারা যাচাই করা হয়।'
                      : 'Users can submit recipes that include ingredients, cuisine, instructions, estimated time, dish type, amount of each ingredient, image of the food and optional YouTube links. These recipes are reviewed by an admin before they appear in the app.',
                ),
                SectionCard(
                  title: isBangla ? '৫. ইউটিউব লিংক' : '5. YouTube Links',
                  body: isBangla
                      ? 'সব রেসিপিতে ইউটিউব ভিডিও লিংক থাকতে পারে। Platr ইউটিউব থেকে কোন ডেটা সংগ্রহ করে না এবং লিংক ব্যবহারের ক্ষেত্রে ইউটিউবের গোপনীয়তা নীতি প্রযোজ্য।'
                      : 'All recipes should include YouTube video links. Platr does not collect data from YouTube, and your use of those links is subject to YouTube’s privacy policy.',
                ),
                SectionCard(
                  title: isBangla ? '৬. তথ্য ভাগাভাগি' : '6. Data Sharing',
                  body: isBangla
                      ? 'আমরা আপনার তথ্য বিজ্ঞাপনদাতাদের বা তৃতীয় পক্ষের সঙ্গে বিক্রি বা ভাগাভাগি করি না। শুধুমাত্র আইন অনুযায়ী বা আপনার সম্মতিতে তথ্য শেয়ার করা হতে পারে।'
                      : 'We do not sell or share your data with advertisers or third parties. We may share information only if required by law or if you give consent.',
                ),
                SectionCard(
                  title: isBangla ? '৭. আপনার অধিকার' : '7. Your Rights',
                  body: isBangla
                      ? 'আপনার অধিকার সমূহ:\n- আপনার অ্যাকাউন্টের তথ্য দেখা ও হালনাগাদ করা\n- অ্যাকাউন্ট মুছে ফেলার অনুরোধ\n- জমাকৃত কনটেন্ট রিপোর্ট বা অপসারণ'
                      : 'You have the right to:\n- View and update your account details\n- Request deletion of your account\n- Report and remove any submitted content',
                ),
                SectionCard(
                  title: isBangla ? '৮. নিরাপত্তা' : '8. Security',
                  body: isBangla
                      ? 'আপনার তথ্য Firebase Authentication ও Realtime Database এর মাধ্যমে নিরাপদে সংরক্ষিত হয়। শুধুমাত্র অনুমোদিত ব্যবহারকারীরা কনটেন্ট ম্যানেজ করতে পারে।'
                      : 'Your data is securely stored using Firebase Authentication and Realtime Database. Only authorized users have access to manage or review content.',
                ),
                SectionCard(
                  title: isBangla ? '৯. নীতির পরিবর্তন' : '9. Changes to This Policy',
                  body: isBangla
                      ? 'আমরা সময়ে সময়ে এই গোপনীয়তা নীতি আপডেট করতে পারি। বড় কোন পরিবর্তন অ্যাপের মাধ্যমে জানানো হবে।'
                      : 'We may update this Privacy Policy as our features grow. Significant changes will be notified through the app.',
                ),
                SectionCard(
                  title: isBangla ? '১০. যোগাযোগ করুন' : '10. Contact Us',
                  body: isBangla
                      ? 'আপনি নিচের ইমেইলগুলোতে আমাদের সাথে যোগাযোগ করতে পারেনঃ'
                      : 'You can contact us via the following emails:',
                ),

                // Team contact cards
                const PersonEmailCard(
                  name: 'Anika Sanzida Upoma',
                  email: 'anikasanzida31593@gmail.com',
                  imagePath: 'assets/profiles/anika.jpeg',
                ),
                const PersonEmailCard(
                  name: 'Suraya Jannat Mim',
                  email: 'mimrobo1726@gmail.com',
                  imagePath: 'assets/profiles/mim.jpeg',
                ),
                const PersonEmailCard(
                  name: 'Ishrat Jahan Mim',
                  email: 'ishratjahan7711@gmail.com',
                  imagePath: 'assets/profiles/ishrat.jpeg',
                ),
                const PersonEmailCard(
                  name: 'Tasmia Sultana Sumi',
                  email: 'sumitasmia515@gmail.com',
                  imagePath: 'assets/profiles/sumi.jpeg',
                ),

                const SizedBox(height: 30),
                Center(
                  child: Text(
                    isBangla ? 'সর্বশেষ হালনাগাদ: ৮ জুলাই, ২০২৫' : 'Last Updated: July 8, 2025',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- REUSABLE WIDGETS ----------
class SectionCard extends StatelessWidget {
  final String title;
  final String body;

  const SectionCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 15, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class PersonEmailCard extends StatelessWidget {
  final String name;
  final String email;
  final String imagePath;

  const PersonEmailCard({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
  });

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Platr App Privacy Inquiry'),
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: _launchEmail,
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
