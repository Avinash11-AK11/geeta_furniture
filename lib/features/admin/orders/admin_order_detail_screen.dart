import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../products/product_detail_screen.dart';

import '../../../core/theme/app_colors.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final String orderId;

  // const AdminOrderDetailScreen({super.key, required this.orderId});
  const AdminOrderDetailScreen({super.key, required this.orderId});

  // ================= DATE FORMAT =================

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';

    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }

    return '';
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final user = data['user'] ?? {};
          final product = data['product'] ?? {};
          final request = data['request'] ?? {};
          final timeline = List<Map<String, dynamic>>.from(
            data['timeline'] ?? [],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Customer'),
                _card(
                  Column(
                    children: [
                      _infoRow('Name', user['name']),
                      _infoRow('Phone', user['phone']),
                      _infoRow('Email', user['email']),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final phone = user['phone'];
                            if (phone != null && phone.toString().isNotEmpty) {
                              launchUrl(
                                Uri.parse('tel:$phone'),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.call),
                          label: const Text('Call Customer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _sectionTitle('Product'),
                _card(
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      final productId = product['id'];

                      if (productId == null || productId.toString().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product not linked'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(productId: productId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(child: _infoRow('Name', product['name'])),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                _sectionTitle('Inquiry Message'),
                _card(
                  Text(
                    request['message'] ?? '-',
                    style: const TextStyle(height: 1.5, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 28),

                _sectionTitle('Order Status'),
                _card(_statusDropdown(context, data['status'])),

                const SizedBox(height: 28),

                _sectionTitle('Timeline'),
                if (timeline.isEmpty)
                  const Text(
                    'No history yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  Column(
                    children: timeline.reversed.map((e) {
                      final status = (e['status'] ?? '')
                          .toString()
                          .replaceAll('_', ' ')
                          .toUpperCase();

                      final by = e['by'] ?? '';
                      final time = _formatDate(e['time']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$by • $time',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= STATUS UPDATE =================

  Widget _statusDropdown(BuildContext context, String currentStatus) {
    const statuses = [
      'request_received',
      'confirmed',
      'in_production',
      'ready',
      'delivered',
      'cancelled',
    ];

    return DropdownButtonFormField<String>(
      value: currentStatus,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: statuses
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(s.replaceAll('_', ' ').toUpperCase()),
            ),
          )
          .toList(),
      onChanged: (value) async {
        if (value == null || value == currentStatus) return;

        try {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({
                'status': value,
                'timeline': FieldValue.arrayUnion([
                  {'status': value, 'by': 'admin', 'time': Timestamp.now()},
                ]),
              });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order status updated'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
