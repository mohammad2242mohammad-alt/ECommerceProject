import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPrice != null &&
        product.discountPrice! < product.price;

    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 55,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
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
                      (product.ratingAverage ?? 0).toString(),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (hasDiscount) ...[
                  Text(
                    '${product.price} تومان',
                    style: const TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.discountPrice} تومان',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  Text(
                    '${product.price} تومان',
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