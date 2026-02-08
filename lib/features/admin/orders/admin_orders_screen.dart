import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_order_detail_screen.dart';

import '../../../core/theme/app_colors.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Stream<QuerySnapshot> _ordersStream() {
    return FirebaseFirestore.instance.collection('orders').snapshots();
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final docs = snapshot.data!.docs.toList();

          docs.sort((a, b) {
            final aTime =
                (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            final bTime =
                (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final user = data['user'] as Map<String, dynamic>?;

              final statusLabel = _displayStatus(data['status'] ?? 'New');

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminOrderDetailScreen(orderId: doc.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME + STATUS
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user?['name'] ?? 'Customer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                statusLabel,
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(statusLabel),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // PHONE
                      if ((user?['phone'] ?? '').isNotEmpty)
                        Text(
                          user!['phone'],
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),

                      const SizedBox(height: 12),

                      // CREATED DATE
                      if (data['createdAt'] != null)
                        Text(
                          (data['createdAt'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(0, 16),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
