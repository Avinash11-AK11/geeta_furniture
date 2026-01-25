import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ ADD THIS IMPORT
import '../constants/admin_credentials.dart';

class AdminSession {
  static const String _isAdminKey = 'is_admin';

  // 🔑 In-memory cache
  static bool _cachedIsAdmin = false;
  static bool _initialized = false;

  /// Initialize admin role ONCE
  static Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _cachedIsAdmin = prefs.getBool(_isAdminKey) ?? false;
    _initialized = true;
  }

  /// Set admin role
  static Future<void> setAdmin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminKey, value);

    _cachedIsAdmin = value;
    _initialized = true;
  }

  /// Get admin role (SAFE) - FIXED VERSION
  static Future<bool> isAdmin() async {
    await init();

    // ✅ Get current Firebase user
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false; // No user logged in
    }

    // ✅ Check if current user's email matches admin credentials
    final isAdminByEmail = currentUser.email == AdminCredentials.adminEmail;

    // ✅ Return true if either stored preference OR email matches
    return _cachedIsAdmin || isAdminByEmail;
  }

  /// Clear admin session (LOGOUT)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isAdminKey);

    // 🔥 FULL RESET (CRITICAL)
    _cachedIsAdmin = false;
    _initialized = false;
  }

  /// Force reset (optional, dev/debug safety)
  static void reset() {
    _cachedIsAdmin = false;
    _initialized = false;
  }
}
