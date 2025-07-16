import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalRecipeDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot? recipe;

  const PersonalRecipeDetailsPage({Key? key, this.recipe}) : super(key: key);

  @override
  State<PersonalRecipeDetailsPage> createState() => _PersonalRecipeDetailsPageState();
}

class _PersonalRecipeDetailsPageState extends State<PersonalRecipeDetailsPage> {
  // ----------------- controllers -----------------
  final titleController        = TextEditingController();
  final descriptionController  = TextEditingController();
  final durationController     = TextEditingController();
  final ingredientsController  = TextEditingController();
  final instructionsController = TextEditingController();
  final cuisineController      = TextEditingController();

  // ------------------------------------------------
  File?         _selectedImage;
  final _picker = ImagePicker();
  static const deepOrange = Color(0xFFFF5722);

  final mealTypes = ['Breakfast', 'Snacks', 'Dessert', 'Lunch', 'Dinner'];
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      final data = widget.recipe!.data() as Map<String, dynamic>;
      titleController.text        = data['title']        ?? '';
      descriptionController.text  = data['description']  ?? '';
      durationController.text     = data['duration']     ?? '';
      ingredientsController.text  = data['ingredients']  ?? '';
      instructionsController.text = data['instructions'] ?? '';
      cuisineController.text      = data['cuisine']      ?? '';
      _selectedMealType           = data['mealType']     ?? '';
    }
  }

  // ------------------------ submit ------------------------
  Future<void> _submitRecipe() async {
    if (_anyFieldEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill every field and pick an image.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    // 1️⃣ upload image if the user chose / changed it
    String? imageUrl;
    if (_selectedImage != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('personal_recipes/${user.uid}/$fileName.jpg');                       // FIX path – per‑user
      try {
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        debugPrint('Image upload failed: $e');                                        // NEW
      }
    }

    // 2️⃣ build document
    final data = {
      'title'        : titleController.text.trim(),
      'description'  : descriptionController.text.trim(),
      'duration'     : durationController.text.trim(),
      'ingredients'  : ingredientsController.text.trim(),
      'instructions' : instructionsController.text.trim(),
      'cuisine'      : cuisineController.text.trim(),
      'mealType'     : _selectedMealType!.trim(),
      'approved'     : false,
      'authorId'     : user.uid,                          // NEW
      'authorEmail'  : user.email,                        // NEW
      'createdAt'    : Timestamp.now(),
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      data['imageUrl'] = imageUrl;
    } else if (widget.recipe != null) {
      data['imageUrl'] = (widget.recipe!.data() as Map<String, dynamic>)['imageUrl'] ?? '';
    }

    // 3️⃣ write
    if (widget.recipe == null) {
      await FirebaseFirestore.instance.collection('pending_recipes').add(data);
    } else {
      await FirebaseFirestore.instance.collection('pending_recipes').doc(widget.recipe!.id).update(data);
    }

    // 4️⃣ UX feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.recipe == null
            ? 'Recipe submitted – waiting for approval'
            : 'Recipe updated'),
      ));
      if (widget.recipe == null) _resetForm();
    }
  }

  bool get _anyFieldEmpty =>
      titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          durationController.text.isEmpty ||
          ingredientsController.text.isEmpty ||
          instructionsController.text.isEmpty ||
          cuisineController.text.isEmpty ||
          _selectedMealType == null ||
          (_selectedImage == null && widget.recipe == null);

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    durationController.clear();
    ingredientsController.clear();
    instructionsController.clear();
    cuisineController.clear();
    setState(() {
      _selectedImage   = null;
      _selectedMealType = null;
    });
  }

  // ------------------------ UI helpers ------------------------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Add $label', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _mealDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    final recipeData = widget.recipe?.data() as Map<String, dynamic>?;
    final url        = recipeData?['imageUrl'];

    Widget inner;
    if (_selectedImage != null) {
      inner = Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity);
    } else if (url != null && url.isNotEmpty) {
      inner = Image.network(url, fit: BoxFit.cover, width: double.infinity);
    } else {
      inner = const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Image', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ------------------------ build ------------------------
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
          Positioned.fill(child: Image.asset('assets/screen_images/screen2.jpg', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _field('Title',         titleController),
                _field('Description',   descriptionController, maxLines: 3),
                _field('Duration',      durationController),
                _mealDropdown(),
                _imagePicker(),
                _field('Ingredients',   ingredientsController, maxLines: 3),
                _field('Instructions',  instructionsController, maxLines: 3),
                _field('Cuisine',       cuisineController),
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
