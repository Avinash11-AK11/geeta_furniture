import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class OrderInquiryScreen extends StatefulWidget {
  final String? productName;

  const OrderInquiryScreen({super.key, this.productName});

  @override
  State<OrderInquiryScreen> createState() => _OrderInquiryScreenState();
}

class _OrderInquiryScreenState extends State<OrderInquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _productController = TextEditingController();
  final _messageController = TextEditingController();

  static const String _whatsappNumber = '919313720047';

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

  /* ================= SEND TO WHATSAPP ================= */

  Future<void> _sendWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    final message =
        '''
Hello Geeta Ply & Furniture,

Customer Inquiry:

Name: ${_nameController.text.trim()}
Phone: ${_phoneController.text.trim()}
Product: ${_productController.text.trim().isEmpty ? 'Not specified' : _productController.text.trim()}

Message:
${_messageController.text.trim()}
''';

    final uri = Uri.parse(
      'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(message)}',
    );

    final fallback = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open WhatsApp'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                /// HEADER
                const Text(
                  'Send Inquiry',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in your details and our team will contact you on WhatsApp.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                /// FORM
                _buildForm(),

                const SizedBox(height: 28),

                /// CTA
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _sendWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6ED36F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Send Inquiry on WhatsApp',
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
