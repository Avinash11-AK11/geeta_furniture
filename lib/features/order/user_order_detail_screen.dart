import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/furniture_details_screen.dart';

import '../../core/theme/app_colors.dart';

class UserOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const UserOrderDetailScreen({super.key, required this.orderId});

  // ================= STATUS HELPERS =================

  String _displayStatus(String raw) {
    switch (raw) {
      case 'request_received':
        return 'New';
      case 'confirmed':
        return 'Confirmed';
      case 'in_production':
        return 'In Production';
      case 'ready':
        return 'Ready';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return raw;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'In Production':
        return Colors.purple;
      case 'Ready':
        return Colors.teal;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
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
          final product = data['product'] ?? {};
          final request = data['request'] ?? {};
          final timeline = List<Map<String, dynamic>>.from(
            data['timeline'] ?? [],
          );

          final statusLabel = _displayStatus(data['status'] ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= ORDER NUMBER =================
                Text(
                  data['orderNumber'] ?? 'Order',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 18),

                // ================= PRODUCT =================
                _sectionTitle('Product'),
                _card(
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      final productId = product['id'];
                      if (productId == null || productId.toString().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product not available'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FurnitureDetailsScreen(itemId: productId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'] ?? 'Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ================= STATUS =================
                _sectionTitle('Current Status'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(statusLabel).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _statusColor(statusLabel),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // ================= MESSAGE =================
                _sectionTitle('Your Inquiry'),
                _card(
                  Text(
                    request['message'] ?? '-',
                    style: const TextStyle(height: 1.5),
                  ),
                ),

                const SizedBox(height: 28),

                // ================= TIMELINE =================
                _sectionTitle('Order Timeline'),
                if (timeline.isEmpty)
                  const Text(
                    'No updates yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  Column(
                    children: timeline.reversed.map((item) {
                      final label = _displayStatus(item['status'] ?? '').trim();
                      final time = _formatDate(item['time']);

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
                            Icon(
                              Icons.check_circle_outline,
                              size: 22,
                              color: _statusColor(label),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (time.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
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

  // ================= UI HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
