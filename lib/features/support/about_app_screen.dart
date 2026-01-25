import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          'About App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          /// BRAND CARD (LOGO FIXED HERE)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                /// LOGO (NO CIRCLE, NO BLUR)
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 72,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Geeta Ply & Furniture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  'Quality furniture for every home',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          /// ABOUT US
          _infoCard(
            title: 'About Us',
            content:
                'Geeta Ply & Furniture is a trusted local furniture store offering premium quality furniture crafted for modern Indian homes. We focus on durability, comfort, and timeless design.',
          ),

          /// OUR VISION
          _infoCard(
            title: 'Our Vision',
            content:
                'To provide honest pricing, superior craftsmanship, and reliable customer support while building long-term trust with our customers.',
          ),

          /// APP VERSION
          _infoCard(title: 'App Version', content: 'Version 1.0.0'),
        ],
      ),
    );
  }

  /// CLEAN INFO CARD
  Widget _infoCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
