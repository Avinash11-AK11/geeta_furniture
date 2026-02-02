import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Stream<QuerySnapshot> _ordersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF6F2EB),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F2EB),
        title: const Text(
          'Orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _OrderCard(
                orderId: doc.id,
                customerName: data['customerName'] ?? 'Customer',
                phone: data['phone'] ?? '',
                status: data['status'] ?? 'New',
                createdAt: data['createdAt'],
              );
            },
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String phone;
  final String status;
  final dynamic createdAt;

  const _OrderCard({
    required this.orderId,
    required this.customerName,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  Color _statusColor() {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // PHONE
          if (phone.isNotEmpty)
            Text(phone, style: const TextStyle(color: AppColors.textSecondary)),

          const SizedBox(height: 14),

          // ACTIONS
          Row(
            children: [
              _ActionButton(
                label: 'Update Status',
                onTap: () {
                  _showStatusSheet(context, orderId, status);
                },
              ),
              const SizedBox(width: 12),
              _ActionButton(
                label: 'View Details',
                outlined: true,
                onTap: () {
                  // future: order details screen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.white : AppColors.textPrimary,
          foregroundColor: outlined ? AppColors.textPrimary : Colors.white,
          elevation: outlined ? 0 : 2,
          side: outlined
              ? const BorderSide(color: AppColors.textPrimary)
              : null,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

// ----------------------------------------------------------------

void _showStatusSheet(
  BuildContext context,
  String orderId,
  String currentStatus,
) {
  final statuses = [
    'New',
    'Confirmed',
    'In Production',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Order Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...statuses.map((status) {
              return ListTile(
                title: Text(status),
                trailing: status == currentStatus
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .update({'status': status});
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      );
    },
  );
}
