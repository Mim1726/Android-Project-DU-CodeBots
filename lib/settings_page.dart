import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final String language;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;
  final Function(String) onLanguageChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.language,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isDarkMode;
  late double fontSize;
  late String language;
  bool recipeAlerts = true;
  bool recipeReminders = false;
  String preferredCuisine = 'Italian';
  String dietType = 'Vegetarian';

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    fontSize = widget.fontSize;
    language = widget.language;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recipeAlerts = prefs.getBool('recipeAlerts') ?? true;
      recipeReminders = prefs.getBool('recipeReminders') ?? false;
      preferredCuisine = prefs.getString('preferredCuisine') ?? 'Italian';
      dietType = prefs.getString('dietType') ?? 'Vegetarian';
    });
  }

  Future<void> _updatePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setString('language', language);
    await prefs.setBool('recipeAlerts', recipeAlerts);
    await prefs.setBool('recipeReminders', recipeReminders);
    await prefs.setString('preferredCuisine', preferredCuisine);
    await prefs.setString('dietType', dietType);
  }

  void _sendEmail(String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      queryParameters: {'subject': subject},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client')),
      );
    }
  }

  void _showCuisineDialog() {
    final cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'Bangladeshi', 'Japanese','Turkish','American'];
    String tempSelected = preferredCuisine;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Preferred Cuisine'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: cuisines.map((cuisine) {
                return RadioListTile<String>(
                  title: Text(cuisine),
                  value: cuisine,
                  groupValue: tempSelected,
                  onChanged: (value) => setState(() => tempSelected = value!),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => preferredCuisine = tempSelected);
              _updatePreferences();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Preferred Cuisine: $preferredCuisine')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDietDialog() {
    final diets = ['Vegetarian', 'Vegan', 'Non-Vegetarian', 'Keto'];
    String tempSelected = dietType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Diet Type'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: diets.map((diet) {
                return RadioListTile<String>(
                  title: Text(diet),
                  value: diet,
                  groupValue: tempSelected,
                  onChanged: (value) => setState(() => tempSelected = value!),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => dietType = tempSelected);
              _updatePreferences();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Diet Type: $dietType')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Edit Profile'),
            leading: const Icon(Icons.person),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage(initialData: {},))),
          ),
          const Divider(),

          const Text('Preferred Cuisine', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Select Preferred Cuisine'),
            subtitle: Text(preferredCuisine),
            leading: const Icon(Icons.fastfood),
            onTap: _showCuisineDialog,
          ),
          ListTile(
            title: const Text('Diet Type'),
            subtitle: Text(dietType),
            leading: const Icon(Icons.food_bank),
            onTap: _showDietDialog,
          ),
          const Divider(),

          const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
              widget.onThemeChanged(value);
              _updatePreferences();
            },
          ),
          ListTile(
            title: const Text('Font Size Preference'),
            subtitle: Slider(
              value: fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: fontSize.round().toString(),
              onChanged: (value) {
                setState(() => fontSize = value);
                widget.onFontSizeChanged(value);
                _updatePreferences();
              },
            ),
          ),
          const Divider(),

          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Recipe Alerts'),
            value: recipeAlerts,
            onChanged: (value) {
              setState(() => recipeAlerts = value);
              _updatePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Recipe Reminders'),
            value: recipeReminders,
            onChanged: (value) {
              setState(() => recipeReminders = value);
              _updatePreferences();
            },
          ),
          const Divider(),

          const Text('Language Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(language),
            leading: const Icon(Icons.language),
            onTap: () {
              final newLang = language == 'English' ? 'Bangla' : 'English';
              setState(() => language = newLang);
              widget.onLanguageChanged(newLang);
              _updatePreferences();
            },
          ),
          const Divider(),

          const Text('Feedback & About', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Send Feedback'),
            leading: const Icon(Icons.feedback),
            onTap: () => _sendEmail('App Feedback'),
          ),
          ListTile(
            title: const Text('Report Bug'),
            leading: const Icon(Icons.bug_report),
            onTap: () => _sendEmail('Bug Report'),
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
