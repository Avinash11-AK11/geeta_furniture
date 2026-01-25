import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/admin_session.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🏷️ TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Admin Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 👤 ADMIN AVATAR
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.textPrimary.withOpacity(0.1),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 48,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // 📧 ADMIN EMAIL
            Text(
              user?.email ?? 'Admin',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              'Administrator',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 48),

            // 🚪 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  // 🔐 LOGOUT (ORDER MATTERS)
                  await FirebaseAuth.instance.signOut();
                  await AdminSession.clear();
                  // ❌ DO NOT NAVIGATE
                  // AppRouter will rebuild automatically
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
