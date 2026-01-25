import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/sign_in_screen.dart';
import '../../features/admin/admin_scaffold.dart';
import '../../common/main_scaffold.dart';
import '../services/admin_session.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // ⏳ AUTH STATE LOADING
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // 🔴 NOT LOGGED IN
        if (user == null) {
          return const SignInScreen();
        }

        // 🟢 LOGGED IN → CHECK ROLE
        return FutureBuilder<bool>(
          key: ValueKey(user.uid), // ✅ forces rebuild on user change
          future: AdminSession.isAdmin(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Failed to verify user role',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            // 👑 ADMIN
            if (roleSnapshot.data == true) {
              return const AdminScaffold();
            }

            // 👤 NORMAL USER
            return const MainScaffold();
          },
        );
      },
    );
  }
}
