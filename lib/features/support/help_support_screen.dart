import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _phone = '+919313720047';
  static const String _whatsapp = '919313720047';

  Future<void> _callStore() async {
    await launchUrl(
      Uri(scheme: 'tel', path: _phone),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openWhatsApp() async {
    await launchUrl(
      Uri.parse('https://wa.me/$_whatsapp'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// FAQ
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          _faqTile(
            question: 'How can I place an order?',
            answer:
                'To place an order, please call our store directly. Our team will guide you through product details, pricing, and availability.',
          ),
          _faqTile(
            question: 'Do you provide home delivery?',
            answer:
                'Currently, we do not provide home delivery. Please contact the store for pickup and transport guidance.',
          ),
          _faqTile(
            question: 'Can I customize furniture?',
            answer:
                'Yes, customization is available for selected furniture items. Please call the store to discuss your requirements.',
          ),

          const SizedBox(height: 30),

          /// CONTACT
          const Text(
            'Contact Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          _contactTile(
            icon: Icons.call,
            title: 'Call Store',
            subtitle: _phone,
            onTap: _callStore,
          ),
          _contactTile(
            icon: Icons.chat_bubble_outline,
            title: 'WhatsApp',
            subtitle: 'Chat for queries',
            onTap: _openWhatsApp,
          ),
        ],
      ),
    );
  }

  Widget _faqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
