class AuthValidator {
  // ================= NAME =================
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Name is required';
    }

    if (name.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null; // valid
  }

  // ================= EMAIL =================
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ================= PASSWORD =================
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
}
