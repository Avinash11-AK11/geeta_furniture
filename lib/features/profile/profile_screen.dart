import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/storage/profile_storage.dart';
import '../../core/storage/profile_image_service.dart';
import '../../core/firestore/user_profile_service.dart';
import '../../common/notification_manager.dart';
import '../../common/fcm_service.dart';

import 'account_info_screen.dart';
import 'profile_skeleton.dart';
import '../support/help_support_screen.dart';
import '../support/about_app_screen.dart';
import '../order/user_orders_screen.dart'; // ✅ ADDED

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = UserProfileService();
  final _picker = ImagePicker();

  File? _profileImage;
  bool _uploadingImage = false;

  bool _notificationsEnabled = true;
  bool _loadingPrefs = true;

  /* ================= INIT ================= */

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    await NotificationManager.instance.loadFromStorage();
    final image = await ProfileStorage.loadProfileImage();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = NotificationManager.instance.enabled;
      _profileImage = image;
      _loadingPrefs = false;
    });
  }

  /* ================= PROFILE IMAGE ================= */

  Future<void> _changeProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked == null) return;

    setState(() => _uploadingImage = true);

    try {
      final file = File(picked.path);

      final String? url = await ProfileImageService.uploadProfileImage(file);

      if (url == null || url.isEmpty) {
        throw Exception('Upload failed');
      }

      await _profileService.updatePhotoUrl(url);
      await ProfileStorage.saveProfileImage(file);

      if (mounted) {
        setState(() => _profileImage = file);
      }
    } catch (e) {
      _showError('Failed to update profile image');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  /* ================= NOTIFICATIONS ================= */

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);

    NotificationManager.instance.setEnabled(value);

    if (value) {
      FCMService.instance.enable();
    } else {
      FCMService.instance.disable();
    }
  }

  /* ================= LOGOUT ================= */

  Future<void> _logout() async {
    await NotificationManager.instance.resetOnLogout();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) await _logout();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const ProfileSkeleton();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _profileService.userProfileStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const ProfileSkeleton();

          final data = snapshot.data ?? {};
          final user = FirebaseAuth.instance.currentUser;

          final name = data['name'] ?? 'User';
          final email = data['email'] ?? (user?.email ?? '');
          final photoUrl = data['photoUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _profileHeader(name, email, photoUrl),
                const SizedBox(height: 32),
                _menuSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ================= HEADER ================= */

  Widget _profileHeader(String name, String email, String? photoUrl) {
    final ImageProvider? imageProvider = _profileImage != null
        ? FileImage(_profileImage!)
        : (photoUrl != null && photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: AppColors.textSecondary.withOpacity(0.15),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    )
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Material(
                shape: const CircleBorder(),
                color: AppColors.background,
                elevation: 3,
                child: InkWell(
                  onTap: _uploadingImage ? null : _changeProfileImage,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  /* ================= MENU ================= */

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Account'),
        _profileTile(Icons.person_outline, 'Account Information', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountInformationScreen()),
          );
        }),
        _profileTile(Icons.receipt_long, 'My Orders', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserOrdersScreen()),
          );
        }),
        const SizedBox(height: 24),
        _sectionTitle('Preferences'),
        _notificationTile(),
        const SizedBox(height: 24),
        _sectionTitle('Support'),
        _profileTile(Icons.help_outline, 'Help & Support', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          );
        }),
        _profileTile(Icons.info_outline, 'About App', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutAppScreen()),
          );
        }),
        const SizedBox(height: 28),
        _logoutTile(),
      ],
    );
  }

  Widget _notificationTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        title: const Text('Notifications'),
        secondary: const Icon(Icons.notifications_none),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _logoutTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: _confirmLogout,
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
