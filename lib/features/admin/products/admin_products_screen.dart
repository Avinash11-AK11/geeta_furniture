import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../categories/category_list_screen.dart';

import 'product_categories.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER (REPLACES APPBAR) =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    // 🔹 Manage Categories Button
                    IconButton(
                      icon: const Icon(Icons.category_outlined),
                      tooltip: 'Manage Categories',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryListScreen(),
                          ),
                        );
                      },
                    ),

                    // 🔹 Add Product Button (existing)
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Product',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductFormScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= CATEGORY FILTER =================
          SizedBox(
            height: 44,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: productCategories.length,
              itemBuilder: (_, index) {
                final category = productCategories[index];
                final isSelected = category == selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ================= PRODUCTS GRID =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (selectedCategory == 'All') return true;
                  return data['category'] == selectedCategory;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // final images =
                    //     (data['images'] is List && data['images'].isNotEmpty)
                    //     ? data['images']
                    //     : null;
                    //
                    // final imageUrl = images != null
                    //     ? images.first['url']
                    //     : null;

                    final List images = (data['images'] as List?) ?? [];

                    final String? imageUrl =
                        images.isNotEmpty &&
                            images.first is Map &&
                            images.first['url'] != null
                        ? images.first['url'] as String
                        : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: doc.id),
                          ),
                        );
                      },
                      child: _adminProductCard(
                        context: context,
                        name: data['name'] ?? '',
                        price: data['price'] ?? 0,
                        imageUrl: imageUrl,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD (UNCHANGED VISUALS) =================
  Widget _adminProductCard({
    required BuildContext context,
    required String name,
    required num price,
    String? imageUrl,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DED4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Container(
                color: const Color(0xFFF3EEE8),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.chair_alt_outlined,
                          size: 42,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF2E1F14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: const Color(0xFF6F4E37),
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
