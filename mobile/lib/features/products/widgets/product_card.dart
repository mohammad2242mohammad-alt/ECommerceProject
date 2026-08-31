import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPrice != null &&
        product.discountPrice! < product.price;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تصویر محصول
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: product.image != null &&
                        product.image!.isNotEmpty
                    ? Image.network(
                        product.image!,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // نام محصول
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // امتیاز
            if (product.rating != null)
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // قیمت
            if (hasDiscount) ...[
              Text(
                '${formatPrice(product.price)} تومان',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${formatPrice(product.discountPrice!)} تومان',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else
              Text(
                '${formatPrice(product.price)} تومان',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}