import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/storage/cloudinary_service.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final TextEditingController nameController = TextEditingController();
  File? selectedImage;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> saveCategory() async {
    if (nameController.text.isEmpty || selectedImage == null) return;

    setState(() => isLoading = true);

    try {
      final uploadResult = await CloudinaryService.uploadProductImage(
        selectedImage!,
      );

      final imageUrl = uploadResult['url'];

      await FirebaseFirestore.instance.collection('categories').add({
        'name': nameController.text.trim(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Category upload error: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: selectedImage == null
                  ? Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: Text("Pick Category Image")),
                    )
                  : Image.file(selectedImage!, height: 150),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : saveCategory,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
