import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

// ADMIN SCREENS
import 'dashboard/admin_dashboard_screen.dart';
import 'products/admin_products_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'profile/admin_profile_screen.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  static _AdminScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AdminScaffoldState>();
  }

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    AdminProfileScreen(),
  ];

  void changeTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ SINGLE SOURCE OF BACKGROUND (CRITICAL)
      backgroundColor: const Color(0xFFF6F2EB),

      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,
        elevation: 12,

        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,

        selectedFontSize: 12,
        unselectedFontSize: 12,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
