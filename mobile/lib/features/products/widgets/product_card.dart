import 'package:flutter/material.dart';
/// کارت نمایش محصول
///
/// این Widget بعداً اطلاعات را از ProductModel دریافت می‌کند.
/// فعلاً داده‌ها برای تست UI ثابت هستند.
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final double rating;
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.rating,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         // تصویر محصول
       ClipRRect(
         borderRadius: const BorderRadius.vertical(
           top: Radius.circular(16),
         ),
          child: Image.asset(
           image,
           height: 130,
           width: double.infinity,
           fit: BoxFit.cover,
          ),
         ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$price تومان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}