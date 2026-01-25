import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/home/home_screen.dart';
import '../features/visit/user_visit_screen.dart'; // ✅ FIXED IMPORT
import '../features/wishlist/wishlist_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../core/services/admin_session.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  /// 🔹 USER SCREENS (ORDER = BOTTOM NAV)
  final List<Widget> _screens = const [
    HomeScreen(),
    UserVisitScreen(), // ✅ FIXED CLASS NAME
    WishlistScreen(),
    ProfileScreen(),
  ];

  User? _lastUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        // 🔴 USER LOGGED OUT → SIGN IN
        if (user == null) {
          _lastUser = null;
          return const SignInScreen();
        }

        // 🔐 CHECK ADMIN ROLE (BLOCK ADMIN FROM USER UI)
        return FutureBuilder<bool>(
          future: AdminSession.isAdmin(),
          builder: (context, adminSnapshot) {
            if (!adminSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🚫 ADMIN → USER UI NOT ALLOWED
            if (adminSnapshot.data == true) {
              return const SizedBox.shrink(); // Admin router handles this
            }

            // 🟢 USER JUST LOGGED IN → RESET TAB
            if (_lastUser == null && user != null) {
              _currentIndex = 0;
            }

            _lastUser = user;

            // 👤 NORMAL USER UI
            return Scaffold(
              backgroundColor: const Color(0xFFF8F3EE),
              body: _screens[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF6B3F2E),
                unselectedItemColor: Colors.black54,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.location_on),
                    label: 'Visit',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    label: 'Wishlist',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
