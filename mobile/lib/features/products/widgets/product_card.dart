import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';
import '../../../shared/widgets/store_widgets.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap, this.onFavorite});
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              NetworkImageBox(url: product.image, height: 155, width: double.infinity, fit: BoxFit.contain),
              if (product.hasDiscount)
                Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(8)), child: Text('${(((product.price - product.discountPrice!) / product.price) * 100).round()}٪', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
              if (onFavorite != null) Positioned(top: 2, left: 2, child: IconButton(onPressed: onFavorite, icon: const Icon(Icons.favorite_border), tooltip: 'افزودن به علاقه‌مندی‌ها')),
            ]),
            const SizedBox(height: 10),
            Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
            const Spacer(),
            Row(children: [const Icon(Icons.star, size: 16, color: Colors.amber), const SizedBox(width: 3), Text((product.ratingAverage ?? 0).toStringAsFixed(1), style: const TextStyle(fontSize: 12)), const Spacer(), if (product.stock > 0) const Text('موجود', style: TextStyle(color: Colors.green, fontSize: 11)) else const Text('ناموجود', style: TextStyle(color: Colors.red, fontSize: 11))]),
            const SizedBox(height: 6),
            if (product.hasDiscount) Text('${money(product.price)} تومان', style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey)),
            Text('${money(product.currentPrice)} تومان', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Theme.of(context).colorScheme.primary)),
          ]),
        ),
      ),
    );
  }
}
