import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../common/main_scaffold.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'firebase_auth_service.dart';
import '../../core/firestore/user_profile_service.dart';
import '../../core/auth/auth_validator.dart';
import '../../core/auth/firebase_error_mapper.dart';

// ✅ ADMIN
import '../../core/constants/admin_credentials.dart';
import '../../core/services/admin_session.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = FirebaseAuthService();
  final _profileService = UserProfileService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _logoSection(),
              const SizedBox(height: 50),
              _titleSection(),
              const SizedBox(height: 30),
              _signInForm(),
              const SizedBox(height: 40),
              _bottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGO =================
  Widget _logoSection() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 110,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'Geeta Ply & Ply Furniture',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ================= FORM =================
  Widget _signInForm() {
    return Column(
      children: [
        _emailField(),
        const SizedBox(height: 18),
        _passwordField(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _primaryButton(),
      ],
    );
  }

  // ================= EMAIL =================
  Widget _emailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => setState(() => _emailError = null),
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _emailError,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= PASSWORD =================
  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      onChanged: (_) => setState(() => _passwordError = null),
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: _passwordError,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ================= SIGN IN LOGIC =================
  Future<void> _signIn() async {
    setState(() {
      _emailError = AuthValidator.validateEmail(_emailController.text.trim());
      _passwordError = AuthValidator.validatePassword(
        _passwordController.text.trim(),
      );
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 🔐 1. Firebase sign-in for BOTH user & admin
      await _authService.signIn(email: email, password: password);

      // ✅ 2. Get the current Firebase user AFTER successful sign-in
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after sign-in',
        );
      }

      // 🔑 3. Check if this user is admin (by email only)
      final bool isAdmin = currentUser.email == AdminCredentials.adminEmail;

      // 🔥 CRITICAL: Store admin status
      await AdminSession.setAdmin(isAdmin);

      debugPrint('✅ Login successful');
      debugPrint('📧 User email: ${currentUser.email}');
      debugPrint('👑 Is admin: $isAdmin');

      // 👤 4. Create profile ONLY for regular users
      if (!isAdmin) {
        await _profileService.createUserProfileIfNotExists(
          name: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
        );
      }

      // ✅ Navigation is handled by AppRouter automatically
      // NO explicit navigation needed here
    } on FirebaseAuthException catch (e) {
      final message = FirebaseErrorMapper.map(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
      );

      // ❌ Clear admin status on failed login
      await AdminSession.setAdmin(false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );

      // ❌ Clear admin status on error
      await AdminSession.setAdmin(false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= BOTTOM =================
  Widget _bottomSection() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          );
        },
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
