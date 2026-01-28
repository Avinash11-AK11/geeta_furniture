import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/wishlist_manager.dart';
import '../../core/theme/app_colors.dart';
import 'furniture_model.dart';
import '../order/order_inquiry_screen.dart';

class FurnitureDetailsScreen extends StatefulWidget {
  final FurnitureModel item;

  const FurnitureDetailsScreen({super.key, required this.item});

  @override
  State<FurnitureDetailsScreen> createState() => _FurnitureDetailsScreenState();
}

class _FurnitureDetailsScreenState extends State<FurnitureDetailsScreen> {
  int _currentImage = 0;
  final WishlistManager wishlist = WishlistManager.instance;

  List<String> get _images => widget.item.gallery.isNotEmpty
      ? widget.item.gallery
      : [widget.item.image];

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
    final bool isLiked = wishlist.isWishlisted(widget.item);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /* ================= IMAGE (ADMIN STYLE) ================= */
          SliverAppBar(
            backgroundColor: const Color(0xFFF8F3EE),
            expandedHeight: 360,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: _shareProduct,
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                onPressed: () {
                  setState(() => wishlist.toggle(widget.item));
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
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              _images[index],
                              fit: BoxFit.contain,
                              width: double.infinity,
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
                          color: _currentImage == i
                              ? AppColors.accentOrange
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          /* ================= DETAILS (ADMIN STYLE) ================= */
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.item.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentOrange,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F3EE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Category', widget.item.category),
                        const SizedBox(height: 8),
                        _infoRow('Material', 'Solid Wood'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Premium quality furniture crafted with durable materials and elegant design. Ideal for modern homes and everyday use.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /* ================= ACTION BAR (UNCHANGED) ================= */
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
                        builder: (_) =>
                            OrderInquiryScreen(productName: widget.item.name),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
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
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
