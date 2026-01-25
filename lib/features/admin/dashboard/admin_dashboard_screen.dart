import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../admin_scaffold.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<int> _count(String collection) async {
    final snap = await FirebaseFirestore.instance.collection(collection).get();
    return snap.docs.length;
  }

  Future<int> _activeOrders() async {
    final snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isNotEqualTo: 'Delivered')
        .get();
    return snap.docs.length;
  }

  Stream<QuerySnapshot> _recentOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final adminScaffold = AdminScaffold.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F2EB),
        title: const Text(
          'Geeta Ply & Furniture',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: AppColors.textPrimary),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BUSINESS OVERVIEW
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track orders, products and production status',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // METRICS
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              children: [
                _MetricCard(
                  title: 'Customers',
                  icon: Icons.people_outline,
                  future: _count('users'),
                ),
                _MetricCard(
                  title: 'Products',
                  icon: Icons.chair_outlined,
                  future: _count('products'),
                ),
                _MetricCard(
                  title: 'Total Orders',
                  icon: Icons.receipt_long_outlined,
                  future: _count('orders'),
                ),
                _MetricCard(
                  title: 'Ongoing Orders',
                  icon: Icons.local_shipping_outlined,
                  future: _activeOrders(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // OWNER ACTIONS
            const Text(
              'Owner Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            _ActionCard(
              title: 'Add New Product',
              subtitle: 'Create and publish furniture item',
              icon: Icons.add_box_outlined,
              onTap: () {
                adminScaffold?.changeTab(1); // PRODUCTS TAB
              },
            ),

            _ActionCard(
              title: 'Manage Orders',
              subtitle: 'View and update order status',
              icon: Icons.assignment_outlined,
              onTap: () {
                adminScaffold?.changeTab(2); // ORDERS TAB
              },
            ),

            const SizedBox(height: 26),

            // RECENT ORDERS
            StreamBuilder<QuerySnapshot>(
              stream: _recentOrders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _OrderPreviewTile(
                        name: data['customerName'] ?? 'Customer',
                        status: data['status'] ?? '',
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- COMPONENTS ----------------

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<int> future;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: FutureBuilder<int>(
        future: future,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(height: 10),
              Text(
                snapshot.hasData ? snapshot.data.toString() : '—',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _OrderPreviewTile extends StatelessWidget {
  final String name;
  final String status;

  const _OrderPreviewTile({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(status, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
