import 'dart:async';
import 'package:flutter/material.dart';

import 'furniture_model.dart';
import 'furniture_details_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/furniture_card.dart';
import 'widgets/category_section_card.dart';
import '../category_products/category_products_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../common/notification_manager.dart';
import '../../common/empty_state.dart';
import 'home_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  final List<FurnitureModel> furnitureList = const [
    FurnitureModel(
      id: 'wooden-chair',
      name: 'Wooden Chair',
      image: 'assets/images/chair.jpg',
      price: '₹3,499',
      priceValue: 3499,
      category: 'Chairs',
    ),
    FurnitureModel(
      id: 'modern-sofa',
      name: 'Modern Sofa',
      image: 'assets/images/sofa.jpg',
      price: '₹18,999',
      priceValue: 18999,
      category: 'Sofas',
    ),
    FurnitureModel(
      id: 'dining-table',
      name: 'Dining Table',
      image: 'assets/images/table.jpg',
      price: '₹24,999',
      priceValue: 24999,
      category: 'Tables',
    ),
    FurnitureModel(
      id: 'wardrobe',
      name: 'Wardrobe',
      image: 'assets/images/wardrobe.jpg',
      price: '₹32,999',
      priceValue: 32999,
      category: 'Beds',
    ),
  ];

  final List<String> categories = const [
    'All',
    'Chairs',
    'Sofas',
    'Tables',
    'Beds',
  ];

  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _simulateInitialLoad();
  }

  Future<void> _simulateInitialLoad() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  String _categoryImage(String category) {
    switch (category) {
      case 'Sofas':
        return 'assets/images/sofa.jpg';
      case 'Chairs':
        return 'assets/images/chair.jpg';
      case 'Tables':
        return 'assets/images/table.jpg';
      case 'Beds':
        return 'assets/images/wardrobe.jpg';
      default:
        return 'assets/images/chair.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const HomeSkeleton() : _actualHomeContent(context);
  }

  // =====================================================
  // 🔥 REAL HOME CONTENT
  // =====================================================
  Widget _actualHomeContent(BuildContext context) {
    final filtered = furnitureList.where((item) {
      final query = searchQuery.toLowerCase();
      return (selectedCategory == 'All' || item.category == selectedCategory) &&
          (item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query) ||
              item.priceValue.toString().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F3EE),
        elevation: 0,
        title: const Text(
          'Geeta Ply & Furniture',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A2A1E),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: NotificationManager.instance,
            builder: (_, __) {
              final manager = NotificationManager.instance;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      manager.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (manager.hasNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          manager.count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// SEARCH
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search furniture, price, category...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// CATEGORY CHIPS
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final c = categories[i];
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = c),
                  child: CategoryChip(
                    title: c,
                    isSelected: selectedCategory == c,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          /// SHOP BY CATEGORY
          const Text(
            'Shop by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories
                  .where((c) => c != 'All')
                  .map(
                    (c) => CategorySectionCard(
                      title: c,
                      image: _categoryImage(c),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryProductsScreen(
                              category: c,
                              products: furnitureList
                                  .where((item) => item.category == c)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 28),

          /// POPULAR PRODUCTS
          const Text(
            'Popular Furniture',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.chair_outlined,
                  title: 'No products available',
                  subtitle: 'Please try a different search or category.',
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    return FurnitureCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FurnitureDetailsScreen(item: item),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
