import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';

/// کارت نمایش محصول.
///
/// این Widget فقط مسئول نمایش اطلاعات محصول است.
/// دریافت اطلاعات از API در لایه Provider / Service انجام می‌شود.
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

    final displayPrice =
        hasDiscount ? product.discountPrice! : product.price;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // صفحه جزئیات محصول را در مرحله بعد به Route متصل می‌کنیم.
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // تصویر محصول
            // =========================
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 52,
                    color: Color(0xFFB8BBC0),
                  ),
                ),
              ),
            ),

            // =========================
            // اطلاعات محصول
            // =========================
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202329),
                      ),
                    ),

                    const Spacer(),

                    // =========================
                    // قیمت
                    // =========================
                    if (hasDiscount) ...[
                      Text(
                        '${product.price} تومان',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8D91),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$displayPrice تومان',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202329),
                            ),
                          ),
                        ),

                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_discountPercent()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _discountPercent() {
    if (product.price <= 0 || product.discountPrice == null) {
      return 0;
    }

    final percent =
        ((product.price - product.discountPrice!) / product.price) * 100;

    return percent.round();
  }
}