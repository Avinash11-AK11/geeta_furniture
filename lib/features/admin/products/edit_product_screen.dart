import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.productData['name']);
    priceCtrl = TextEditingController(
      text: widget.productData['price'].toString(),
    );
    descCtrl = TextEditingController(text: widget.productData['description']);
  }

  Future<void> _updateProduct() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update({
          'name': nameCtrl.text.trim(),
          'price': double.parse(priceCtrl.text.trim()),
          'description': descCtrl.text.trim(),
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Product Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: priceCtrl,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 4,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _updateProduct,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
