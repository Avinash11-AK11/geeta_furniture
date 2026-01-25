import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Currently logged-in user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Create new user with email & password
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in existing user (USER + ADMIN)
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// 🔐 Forgot Password — send reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// 🔓 Sign out current user (CRITICAL FIX)
  Future<void> signOut() async {
    // ✅ Always sign out — do NOT guard with currentUser
    await _auth.signOut();

    // 🔑 Force auth stream to emit null immediately
    // This guarantees AppRouter rebuild
    await _auth.authStateChanges().first;
  }
}
