import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';

class OrderInquiryScreen extends StatefulWidget {
  final String? productId;
  final String? productName;

  const OrderInquiryScreen({super.key, this.productId, this.productName});

  @override
  State<OrderInquiryScreen> createState() => _OrderInquiryScreenState();
}

class _OrderInquiryScreenState extends State<OrderInquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _productController = TextEditingController();
  final _messageController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _productController.text = widget.productName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _productController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /* ================= SUBMIT INQUIRY ================= */

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to send inquiry'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': 'GF-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'request_received',
        'createdAt': Timestamp.now(),

        // ---------- USER ----------
        'user': {
          'userId': user.uid,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': user.email,
        },

        // ---------- PRODUCT (CRITICAL FIX) ----------
        'product': {
          'id': widget.productId, // ✅ REQUIRED FOR ADMIN NAVIGATION
          'name': _productController.text.trim().isEmpty
              ? 'Not specified'
              : _productController.text.trim(),
        },

        // ---------- REQUEST ----------
        'request': {
          'message': _messageController.text.trim(),
          'source': 'app_inquiry',
        },

        // ---------- TIMELINE ----------
        'timeline': [
          {'status': 'request_received', 'by': 'user', 'time': Timestamp.now()},
        ],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inquiry sent successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send inquiry. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: const BackButton(),
        title: const Text(
          'Order Inquiry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Inquiry',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in your details and our team will contact you shortly.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                _buildForm(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitInquiry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6ED36F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Inquiry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ================= FORM ================= */

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _field(
            label: 'Your Name',
            controller: _nameController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          _field(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (v.trim().length < 10) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          _field(
            label: 'Product',
            controller: _productController,
            hint: 'Optional',
          ),
          _field(
            label: 'Message',
            controller: _messageController,
            maxLines: 4,
            hint: 'Example: I want to know the price and material.',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Message is required' : null,
          ),
        ],
      ),
    );
  }

  /* ================= FIELD ================= */

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
