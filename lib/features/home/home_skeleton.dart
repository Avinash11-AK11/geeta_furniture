import 'package:flutter/material.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Color get _base => const Color(0xFFE6E6E6);
  Color get _highlight => const Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerContainer(height: 28, width: 220),
              const SizedBox(height: 16),

              /// SEARCH BAR
              _shimmerContainer(
                height: 50,
                borderRadius: BorderRadius.circular(18),
              ),

              const SizedBox(height: 16),

              /// CATEGORY CHIPS
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, __) => _shimmerContainer(
                    width: 80,
                    height: 36,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: 5,
                ),
              ),

              const SizedBox(height: 24),

              /// SHOP BY CATEGORY TITLE
              _shimmerContainer(height: 20, width: 160),

              const SizedBox(height: 12),

              /// CATEGORY CARDS
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, __) => _shimmerContainer(
                    width: 220,
                    height: 180,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemCount: 3,
                ),
              ),

              const SizedBox(height: 28),

              /// POPULAR TITLE
              _shimmerContainer(height: 20, width: 180),

              const SizedBox(height: 16),

              /// PRODUCT GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerContainer(
                      height: 160,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    const SizedBox(height: 8),
                    _shimmerContainer(height: 14, width: 120),
                    const SizedBox(height: 6),
                    _shimmerContainer(height: 14, width: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SINGLE SHIMMER BLOCK
  Widget _shimmerContainer({
    double? height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            height: height,
            width: width ?? double.infinity,
            decoration: BoxDecoration(
              color: _base,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
