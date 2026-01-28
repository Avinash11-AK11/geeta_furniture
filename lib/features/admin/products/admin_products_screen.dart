import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ================= FILTERS (UNCHANGED) =================
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
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
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
                  return const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final images =
                        (data['images'] is List && data['images'].isNotEmpty)
                        ? data['images']
                        : null;
                    final imageUrl = images != null
                        ? images.first['url']
                        : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productId: doc.id,
                              data: data,
                            ),
                          ),
                        );
                      },
                      child: adminProductCard(
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

  // ================= PRODUCT CARD (FINAL, FIXED) =================
  Widget adminProductCard({
    required BuildContext context,
    required String name,
    required num price,
    String? imageUrl,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // ✅ CARD BACKGROUND (slightly lighter than screen bg)
        color: const Color(0xFFFBF7F2),

        borderRadius: BorderRadius.circular(20),

        // ✅ SOFT BORDER (separates card from background)
        border: Border.all(
          color: const Color(0xFFE6DED4), // warm subtle border
          width: 1,
        ),

        // ✅ ELEVATION SHADOW (very soft, premium)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== IMAGE SECTION =====
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 1, // perfect square image
              child: Container(
                color: const Color(0xFFF3EEE8), // image placeholder bg
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Center(
                            child: Icon(
                              Icons.chair_alt_outlined,
                              size: 42,
                              color: Color(0xFF6F4E37),
                            ),
                          );
                        },
                      )
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

          // ===== TEXT SECTION =====
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: const Color(0xFF2E1F14),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
