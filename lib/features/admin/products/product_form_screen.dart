import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/storage/cloudinary_service.dart';
// import 'product_categories.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const ProductFormScreen({super.key, this.productId, this.existingData});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,

      // ✅ KEEP underline, but control colors
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6DED6)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF6F4E37), width: 1.4),
      ),

      // 🔥 ERROR STATE — NO RED UNDERLINE
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE6DED6)),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF6F4E37), width: 1.4),
      ),

      // 🔥 LABEL NEVER TURNS RED
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF3A2A1E),
        fontWeight: FontWeight.w500,
      ),

      // 🔥 ERROR TEXT ONLY
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
        height: 1.2,
      ),

      isDense: true,
    );
  }

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _category;
  String? _material;

  bool _saving = false;

  final List<File> _newImages = [];
  final List<Map<String, dynamic>> _existingImages = [];

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      _nameCtrl.text = widget.existingData!['name'] ?? '';
      _priceCtrl.text = widget.existingData!['price']?.toString() ?? '';
      _descCtrl.text = widget.existingData!['description'] ?? '';
      _category = widget.existingData!['category'];
      _material = widget.existingData?['material'];

      if (widget.existingData!['images'] != null) {
        _existingImages.addAll(
          List<Map<String, dynamic>>.from(widget.existingData!['images']),
        );
      }
    }
  }

  Stream<List<String>> _categoriesStream() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => (doc.data()['name'] as String).trim())
              .toList(),
        );
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<List<Map<String, dynamic>>> _uploadImages() async {
    final uploaded = <Map<String, String>>[];

    for (final file in _newImages) {
      uploaded.add(await CloudinaryService.uploadProductImage(file));
    }

    return [..._existingImages, ...uploaded];
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // 2️⃣ CATEGORY VALIDATION (ADD THIS ⬇️⬇️⬇️)
    if (_category == null || _category!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    // ================= IMAGE VALIDATION =================

    // ADD or EDIT → image is REQUIRED
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      await _showImageRequiredDialog(
        title: widget.productId == null
            ? 'Add Product Image'
            : 'Image Required',
        message: widget.productId == null
            ? 'Please add at least one image to publish the product.'
            : 'A product must have at least one image. Please add an image before updating.',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final images = await _uploadImages();
      final bool isEdit = widget.productId != null;

      final data = {
        'name': _nameCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'material': _material,
        'images': images,

        // 🔑 USER PANEL VISIBILITY
        // 'isActive': true,
        'isActive': isEdit ? (widget.existingData?['isActive'] ?? true) : true,

        // 🔐 ADMIN TRACE
        'createdBy': FirebaseAuth.instance.currentUser?.uid,

        'updatedAt': FieldValue.serverTimestamp(),
        if (widget.productId == null) 'createdAt': FieldValue.serverTimestamp(),
      };

      final ref = FirebaseFirestore.instance.collection('products');

      if (widget.productId == null) {
        await ref.add(data);
      } else {
        await ref.doc(widget.productId).update(data);
      }

      Navigator.pop(context);
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _showAddImageDialog() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Product Image'),
        content: const Text(
          'Please add at least one image to publish the product.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4E37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickImages();
            },
            child: const Text('Add Image'),
          ),
        ],
      ),
    );
  }

  // dialog for image add or remove (add product screen & edit product screen)

  Future<void> _showImageRequiredDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message, style: const TextStyle(height: 1.4)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF6F4E37),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // IMAGE PICKER
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE7DD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo_outlined, size: 36),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --- REPLACE ONLY THIS Wrap(...) SECTION --- //
                Wrap(
                  spacing: 8,
                  children: [
                    // ===== EXISTING IMAGES =====
                    ..._existingImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final img = entry.value;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              img['url'],
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // ❌ REMOVE BUTTON
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () async {
                                final removedImage = _existingImages[index];

                                // 1️⃣ Remove from UI immediately
                                setState(() {
                                  _existingImages.removeAt(index);
                                });

                                // 2️⃣ Remove from Cloudinary (PERMANENT)
                                try {
                                  await CloudinaryService.deleteImage(
                                    removedImage['publicId'],
                                  );
                                } catch (e) {
                                  debugPrint('Cloudinary delete failed: $e');
                                }
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6F4E37),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // ===== NEW IMAGES =====
                    ..._newImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              file,
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // ❌ REMOVE BUTTON
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _newImages.removeAt(index);
                                });
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6F4E37),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // CATEGORY
                StreamBuilder<List<String>>(
                  stream: _categoriesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final categories = snapshot.data!;

                    return _fieldCard(
                      DropdownButtonFormField<String>(
                        value: _category,
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _category = v);
                          _formKey.currentState?.validate();
                        },
                        validator: (v) => v == null ? 'Select category' : null,
                        decoration: _inputDecoration('Category'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // MATERIAL
                _fieldCard(
                  DropdownButtonFormField<String>(
                    value: _material,
                    items: const ['Ply', 'Block', 'Solid Wood']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _material = v);
                      _formKey.currentState?.validate();
                    },
                    validator: (v) => v == null ? 'Select material' : null,

                    // decoration: const InputDecoration(
                    //   labelText: 'Material',
                    //   contentPadding: EdgeInsets.symmetric(
                    //     horizontal: 0,
                    //     vertical: 12,
                    //   ),
                    // ),
                    decoration: _inputDecoration('Material'),
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _nameCtrl,
                    // decoration: const InputDecoration(
                    //   labelText: 'Product Name',
                    // ),
                    decoration: _inputDecoration('Product Name'),

                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    // decoration: const InputDecoration(labelText: 'Price'),
                    decoration: _inputDecoration('Price'),

                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    // decoration: const InputDecoration(labelText: 'Description'),
                    decoration: _inputDecoration('Description'),

                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F4E37),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.productId == null
                                    ? Icons.check_circle_outline
                                    : Icons.update,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.productId == null
                                    ? 'Publish Product'
                                    : 'Update Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _fieldCard(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE6DED6), // 🔥 soft border
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
