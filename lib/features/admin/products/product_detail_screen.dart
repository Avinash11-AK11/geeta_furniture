import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> data;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.data,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List images = (widget.data['images'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),

      // ✅ NORMAL APPBAR (NO SLIVER)
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.data['name'] ?? '',
          style: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(
                    productId: widget.productId,
                    existingData: widget.data,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteProduct,
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // =====================================================
          // ✅ IMAGE CAROUSEL (NOW SWIPE WORKS)
          // =====================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (_, index) {
                          return Image.network(
                            images[index]['url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),

                      // ===== DOTS =====
                      if (images.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 6,
                                width: _currentIndex == i ? 18 : 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // ✅ PRODUCT CONTENT (UNCHANGED)
          // =====================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['name'] ?? '',
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1F14),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '₹${widget.data['price'] ?? 0}',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F4E37),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6DED6)),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Category', widget.data['category']),
                        const SizedBox(height: 10),
                        _infoRow('Material', widget.data['material']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['description'] ?? '',
                    style: theme.textTheme.bodyMedium!.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DELETE PRODUCT
  // =====================================================
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: const Color(0xFFFDF8F3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TITLE =====
                const Text(
                  'Delete Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E1F14),
                  ),
                ),

                const SizedBox(height: 12),

                // ===== MESSAGE =====
                const Text(
                  'Are you sure you want to delete this product? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: Color(0xFF5A4636),
                  ),
                ),

                const SizedBox(height: 22),

                // ===== ACTIONS =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6F4E37),
                          side: const BorderSide(color: Color(0xFFE2D7CD)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6F4E37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .delete();

      if (mounted) Navigator.pop(context);
    }
  }

  Widget _infoRow(String label, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF6F4E37),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E1F14),
            ),
          ),
        ),
      ],
    );
  }
}
