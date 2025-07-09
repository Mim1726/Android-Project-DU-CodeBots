import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PersonalRecipeDetailsPage extends StatefulWidget {
  const PersonalRecipeDetailsPage({super.key});

  @override
  State<PersonalRecipeDetailsPage> createState() => _PersonalRecipeDetailsPageState();
}

class _PersonalRecipeDetailsPageState extends State<PersonalRecipeDetailsPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  static const Color deepOrange = Color(0xFFFF5722);

  void _submitRecipe() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        durationController.text.isEmpty ||
        _selectedImage == null ||
        ingredientsController.text.isEmpty ||
        instructionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and select an image")),
      );
      return;
    }

    // Placeholder for Firebase logic

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please wait for admin's approval"),
        duration: Duration(seconds: 2),
      ),
    );

    titleController.clear();
    descriptionController.clear();
    durationController.clear();
    ingredientsController.clear();
    instructionsController.clear();
    setState(() => _selectedImage = null);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add $label", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Add Image", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
                : const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Recipe"),
        backgroundColor: deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField("Title", titleController),
            _buildField("Description", descriptionController, maxLines: 3),
            _buildField("Duration", durationController),
            _buildImagePicker(),
            _buildField("Ingredients", ingredientsController, maxLines: 3),
            _buildField("Instructions", instructionsController, maxLines: 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitRecipe,
        backgroundColor: deepOrange,
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text("Post the recipe", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
