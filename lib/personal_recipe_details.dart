import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'pending_recipes_page.dart';
import 'personal_recipes.dart';

class PersonalRecipeDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot? recipe;

  const PersonalRecipeDetailsPage({Key? key, this.recipe}) : super(key: key);

  @override
  State<PersonalRecipeDetailsPage> createState() => _PersonalRecipeDetailsPageState();
}

class _PersonalRecipeDetailsPageState extends State<PersonalRecipeDetailsPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final ingredientsController = TextEditingController();
  final amountController = TextEditingController(); // New controller for amounts
  final instructionsController = TextEditingController();
  final cuisineController = TextEditingController();
  final youtubeController = TextEditingController(); // New controller for YouTube link

  File? _selectedImage;
  final _picker = ImagePicker();
  static const deepOrange = Color(0xFFFF5722);

  final mealTypes = ['Breakfast', 'Snacks', 'Dessert', 'Lunch', 'Dinner'];
  String? _selectedMealType;

  String? _existingBase64Image;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      final data = widget.recipe!.data() as Map<String, dynamic>;
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      durationController.text = data['duration'] ?? '';
      ingredientsController.text = data['ingredients'] ?? '';
      amountController.text = data['amounts'] ?? '';          // Load amounts if exists
      instructionsController.text = data['instructions'] ?? '';
      cuisineController.text = data['cuisine'] ?? '';
      _selectedMealType = data['mealType'] ?? '';
      _existingBase64Image = data['imageBase64'] ?? '';
      youtubeController.text = data['youtubeLink'] ?? '';    // Load YouTube link if exists
    }
  }

  Future<void> _submitRecipe() async {
    if (_anyFieldEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill every required field and pick an image.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    String? base64Image;

    if (_selectedImage != null) {
      try {
        final compressed = await FlutterImageCompress.compressWithFile(
          _selectedImage!.absolute.path,
          quality: 60,
        );

        if (compressed == null || compressed.length > 1048576) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compressed image must be smaller than 1 MB.')),
          );
          return;
        }

        base64Image = base64Encode(compressed);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image compression failed: $e')),
        );
        return;
      }
    } else {
      base64Image = _existingBase64Image;
    }

    final data = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'duration': durationController.text.trim(),
      'ingredients': ingredientsController.text.trim(),
      'amounts': amountController.text.trim(),           // Save amounts here
      'instructions': instructionsController.text.trim(),
      'cuisine': cuisineController.text.trim(),
      'mealType': _selectedMealType!.trim(),
      'youtubeLink': youtubeController.text.trim(),      // Save YouTube link here
      'approved': false,
      'authorId': user.uid,
      'authorEmail': user.email,
      'createdAt': Timestamp.now(),
      'imageBase64': base64Image ?? '',
    };

    try {
      if (widget.recipe == null) {
        await FirebaseFirestore.instance.collection('pending_recipes').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('pending_recipes')
            .doc(widget.recipe!.id)
            .update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.recipe == null
              ? 'Recipe submitted – waiting for approval'
              : 'Recipe updated'),
        ));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PersonalRecipesPage()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving recipe: $e')),
      );
    }
  }

  bool get _anyFieldEmpty =>
      titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          durationController.text.isEmpty ||
          ingredientsController.text.isEmpty ||
          amountController.text.isEmpty ||                  // Check amount field here
          instructionsController.text.isEmpty ||
          cuisineController.text.isEmpty ||
          _selectedMealType == null ||
          (_selectedImage == null &&
              (widget.recipe == null ||
                  (_existingBase64Image == null || _existingBase64Image!.isEmpty)));

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Widget _field(String label, TextEditingController c,
      {int maxLines = 1, int maxLength = 100}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add $label',
              style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          TextField(
            controller: c,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );

  Widget _mealDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Meal Type',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Select meal type'),
            value: _selectedMealType,
            items: mealTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMealType = v),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _imagePicker() {
    Widget inner;

    if (_selectedImage != null) {
      inner = Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity);
    } else if (_existingBase64Image != null && _existingBase64Image!.isNotEmpty) {
      try {
        final bytes = base64Decode(_existingBase64Image!);
        inner = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
      } catch (e) {
        inner = const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40));
      }
    } else {
      inner = const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Image',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: inner),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _youtubeLinkField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('YouTube Video Link',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      TextField(
        controller: youtubeController,
        maxLines: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'https://www.youtube.com/watch?v=...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: TextInputType.url,
      ),
      const SizedBox(height: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add New Recipe' : 'Edit Recipe'),
        backgroundColor: Colors.white,
        foregroundColor: deepOrange,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/screen_images/screen2.jpg', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _field('Title', titleController, maxLength: 50),
                _field('Description', descriptionController, maxLines: 3, maxLength: 200),
                _field('Duration', durationController, maxLength: 20),
                _mealDropdown(),
                _imagePicker(),
                _field('Ingredients', ingredientsController, maxLines: 3, maxLength: 300),
                _field('Ingredient Amounts', amountController, maxLines: 3, maxLength: 300),
                _field('Instructions', instructionsController, maxLines: 3, maxLength: 500),
                _field('Cuisine', cuisineController, maxLength: 30),
                _youtubeLinkField(), // YouTube link input
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitRecipe,
        backgroundColor: deepOrange,
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Post the recipe', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
