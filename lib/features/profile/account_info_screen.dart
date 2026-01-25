import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../core/firestore/user_profile_service.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _nameController = TextEditingController();
  final _profileService = UserProfileService();

  bool _saving = false;
  bool _hasChanges = false;
  String _initialName = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _detectChanges() {
    final changed = _nameController.text.trim() != _initialName;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    setState(() => _saving = true);

    final newName = _nameController.text.trim();
    await _profileService.updateName(newName);

    if (!mounted) return;
    setState(() {
      _initialName = newName;
      _hasChanges = false;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: const BackButton(),
        title: const Text(
          'Account Information',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _profileService.userProfileStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final photoUrl = data['photoUrl'] as String?;
          final name = data['name'] ?? '';
          final email = user?.email ?? '';

          // 🔒 Initialize controller ONCE per update
          if (_initialName != name) {
            _initialName = name;
            _nameController.text = name;
            _nameController.removeListener(_detectChanges);
            _nameController.addListener(_detectChanges);
          }

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ================= PROFILE IMAGE =================
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.textSecondary.withOpacity(0.15),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 42,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),

                const SizedBox(height: 12),
                Text(email, style: TextStyle(color: AppColors.textSecondary)),

                const SizedBox(height: 32),

                // ================= CARD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERSONAL DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Full Name',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          enabled: false,
                          controller: TextEditingController(text: email),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Email cannot be changed',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!_hasChanges || _saving) ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.textPrimary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
