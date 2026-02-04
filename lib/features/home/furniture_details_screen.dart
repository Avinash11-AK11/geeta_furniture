import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/wishlist_manager.dart';
import '../../core/theme/app_colors.dart';
import 'furniture_model.dart';
import '../order/order_inquiry_screen.dart';

class FurnitureDetailsScreen extends StatelessWidget {
  final FurnitureModel? item;
  final String? itemId;

  const FurnitureDetailsScreen({super.key, this.item, this.itemId});

  @override
  Widget build(BuildContext context) {
    // ✅ CASE 1: Item already available
    if (item != null) {
      return _FurnitureDetailsView(item: item!);
    }

    // ✅ CASE 2: Load product by ID (from order / deep link)
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(itemId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // ================= IMAGE FIX (CRITICAL) =================
        final List images = (data['images'] as List?) ?? [];

        final String primaryImage =
            images.isNotEmpty && images.first['url'] != null
            ? images.first['url']
            : '';

        final List<String> gallery = images
            .where((e) => e['url'] != null)
            .map<String>((e) => e['url'] as String)
            .toList();
        // ========================================================

        final loadedItem = FurnitureModel(
          id: snapshot.data!.id,
          name: data['name'] ?? '',
          image: primaryImage,
          price: '₹${data['price'] ?? 0}',
          priceValue: (data['price'] as num?)?.toInt() ?? 0,
          category: data['category'] ?? '',
          description: data['description'],
          gallery: gallery,
        );

        return _FurnitureDetailsView(item: loadedItem);
      },
    );
  }
}

// ============================================================================
// ========================= ACTUAL UI (UNCHANGED) =============================
// ============================================================================

class _FurnitureDetailsView extends StatefulWidget {
  final FurnitureModel item;

  const _FurnitureDetailsView({required this.item});

  @override
  State<_FurnitureDetailsView> createState() => _FurnitureDetailsViewState();
}

class _FurnitureDetailsViewState extends State<_FurnitureDetailsView> {
  int _currentImage = 0;
  final WishlistManager wishlist = WishlistManager.instance;

  // ✅ SINGLE, CORRECT IMAGE SOURCE
  List<String> get _images => widget.item.gallery.isNotEmpty
      ? widget.item.gallery
      : (widget.item.image.isNotEmpty ? [widget.item.image] : []);

  /* ================= ACTIONS ================= */

  void _shareProduct() {
    final text =
        '${widget.item.name}\n${widget.item.price}\n\nAvailable at Geeta Ply & Furniture';
    Share.share(text);
  }

  Future<void> _callStore() async {
    final uri = Uri(scheme: 'tel', path: '+919313720047');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp() async {
    final phone = '919313720047';
    final message =
        'Hello, I am interested in ${widget.item.name} (${widget.item.price}).';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /* ================= IMAGE ================= */
          SliverAppBar(
            backgroundColor: const Color(0xFFF6F2EB),
            expandedHeight: 360,
            pinned: true,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: _shareProduct,
              ),
              AnimatedBuilder(
                animation: wishlist,
                builder: (context, _) {
                  final isLiked = wishlist.isWishlisted(widget.item);
                  return IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                    ),
                    onPressed: () => wishlist.toggle(widget.item),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 90),
                  Expanded(
                    child: PageView.builder(
                      itemCount: _images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.image)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentImage == i ? 18 : 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          /* ================= DETAILS ================= */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1F14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.price,
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
                        _infoRow('Category', widget.item.category),
                        const SizedBox(height: 10),
                        _infoRow('Material', 'Solid Wood'),
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
                    widget.item.description ?? '',
                    style: theme.textTheme.bodyMedium!.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /* ================= ACTION BAR ================= */
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callStore,
                  icon: const Icon(Icons.call),
                  label: const Text('Call Store'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentOrange,
                    side: const BorderSide(color: AppColors.accentOrange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(Icons.message),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderInquiryScreen(
                          productId: widget.item.id,
                          productName: widget.item.name,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange.withOpacity(0.12),
                    foregroundColor: AppColors.accentOrange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.accentOrange),
                    ),
                  ),
                  child: const Text(
                    'Inquiry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
            value,
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
