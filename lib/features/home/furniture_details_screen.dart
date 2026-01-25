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
          /* ================= HERO IMAGE ================= */
          SliverAppBar(
            backgroundColor: const Color(0xFFF8F3EE),
            expandedHeight: 460,
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
              background: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  /// IMAGE
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => _currentImage = i),
                    itemBuilder: (_, index) {
                      return Container(
                        color: const Color(0xFFF8F3EE),
                        alignment: Alignment.center,
                        child: Image.asset(
                          _images[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),

                  /// INDICATOR (POLISHED)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: List.generate(
                          _images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentImage == i ? 22 : 6,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? AppColors.accentOrange
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /* ================= DETAILS CARD ================= */
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.item.price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Premium quality furniture crafted with durable materials and elegant design. Ideal for modern homes and everyday use.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  _InfoTile(
                    icon: Icons.category,
                    title: 'Category',
                    value: widget.item.category,
                  ),
                  const _InfoTile(
                    icon: Icons.layers,
                    title: 'Material',
                    value: 'Solid Wood',
                  ),
                  const _InfoTile(
                    icon: Icons.store,
                    title: 'Store',
                    value: 'Geeta Ply & Furniture',
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
}

/* ================= INFO TILE ================= */

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text('$title:', style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
