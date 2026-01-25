import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/cloudinary_service.dart';
import 'product_categories.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const ProductFormScreen({super.key, this.productId, this.existingData});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _category;
  String? _material;

  bool _saving = false;

  final List<File> _newImages = [];
  final List<Map<String, String>> _existingImages = [];

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
          List<Map<String, String>>.from(widget.existingData!['images']),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<List<Map<String, String>>> _uploadImages() async {
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

    if (!_formKey.currentState!.validate()) return;

    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product image')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final images = await _uploadImages();

      final data = {
        'name': _nameCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'material': _material,
        'images': images,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
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

                Wrap(
                  spacing: 8,
                  children: [
                    ..._existingImages.map(
                      (img) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          img['url']!,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ..._newImages.map(
                      (img) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          img,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CATEGORY
                _fieldCard(
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: productCategories
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? 'Select category' : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // MATERIAL
                _fieldCard(
                  DropdownButtonFormField<String>(
                    value: _material,
                    items: const ['Ply', 'Block', 'Solid Wood']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _material = v!),
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 16),

                _fieldCard(
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
