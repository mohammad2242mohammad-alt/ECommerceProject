import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';

/// کارت نمایش خلاصه اطلاعات یک محصول.
///
/// این Widget فقط مسئول نمایش اطلاعات محصول است و
/// هیچ درخواست مستقیمی به API ارسال نمی‌کند.
///
/// داده محصول از لایه بالاتر و از طریق [ProductModel]
/// به این Widget ارسال می‌شود.
class ProductCard extends StatelessWidget {
  /// اطلاعات محصولی که باید در کارت نمایش داده شود.
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // بررسی می‌کنیم که آیا محصول تخفیف معتبر دارد یا خیر.
    //
    // تخفیف فقط زمانی معتبر است که:
    // 1. discountPrice وجود داشته باشد.
    // 2. قیمت تخفیف‌خورده از قیمت اصلی کمتر باشد.
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
          // بخش تصویر محصول.
          //
          // فعلاً تصویر واقعی را متصل نمی‌کنیم؛
          // در مراحل بعدی ProductImage و API تصاویر را
          // طبق Contract پروژه اضافه خواهیم کرد.
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

          // اطلاعات متنی محصول.
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // نام محصول.
                //
                // حداکثر دو خط نمایش داده می‌شود تا
                // ارتفاع کارت بیش از حد افزایش پیدا نکند.
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

                // امتیاز محصول.
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

                // نمایش قیمت.
                //
                // اگر محصول تخفیف داشته باشد:
                // قیمت اصلی خط‌خورده نمایش داده می‌شود
                // و قیمت تخفیف‌خورده زیر آن قرار می‌گیرد.
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
                  // اگر تخفیفی وجود نداشته باشد،
                  // فقط قیمت اصلی نمایش داده می‌شود.
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