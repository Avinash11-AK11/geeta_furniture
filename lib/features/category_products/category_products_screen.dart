import 'package:flutter/material.dart';
import '../home/furniture_model.dart';
import '../home/widgets/furniture_card.dart';
import '../home/furniture_details_screen.dart';

enum SortType { none, priceLowHigh, priceHighLow }

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  final List<FurnitureModel> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortType _sortType = SortType.none;

  /// 🔹 SORTED PRODUCTS
  List<FurnitureModel> get _sortedProducts {
    final list = [...widget.products];
    switch (_sortType) {
      case SortType.priceLowHigh:
        list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
        break;
      case SortType.priceHighLow:
        list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
        break;
      case SortType.none:
        break;
    }
    return list;
  }

  /// 🔹 FINAL FILTERED PRODUCTS
  List<FurnitureModel> get _visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _sortedProducts;

    return _sortedProducts.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.priceValue.toString().contains(query);
    }).toList();
  }

  /// 🔹 SORT SHEET
  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              RadioListTile(
                title: const Text('Price: Low to High'),
                value: SortType.priceLowHigh,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),

              RadioListTile(
                title: const Text('Price: High to Low'),
                value: SortType.priceHighLow,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),

              if (_sortType != SortType.none)
                TextButton(
                  onPressed: () {
                    setState(() => _sortType = SortType.none);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear sorting'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),

      /// 🔝 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F3EE),
        iconTheme: const IconThemeData(color: Color(0xFF3A2A1E)),
        title: Text(
          widget.category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A2A1E),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _openSortSheet),
        ],
      ),

      /// 🧱 BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 SEARCH BAR WITH CLEAR ICON
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search in ${widget.category}',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🪑 PRODUCTS / EMPTY STATE
            Expanded(
              child: _visibleProducts.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 64, color: Colors.black38),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Try adjusting your search',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    )
                  : GridView.builder(
                      itemCount: _visibleProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (_, index) {
                        final item = _visibleProducts[index];
                        return FurnitureCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FurnitureDetailsScreen(item: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
