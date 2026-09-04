import 'package:flutter/material.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = [
      'پیشنهاد ویژه امروز',
      'تخفیف محصولات دیجیتال',
      'جدیدترین کالاها',
    ];

    return SizedBox(
      width: double.infinity,
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        physics: const PageScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade300,
              ),
              child: Center(
                child: Text(
                  banners[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}