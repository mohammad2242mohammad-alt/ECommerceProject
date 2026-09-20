import 'package:flutter/material.dart';

import '../../../data/models/product_detail_model.dart';
import '../../../shared/widgets/shared_widgets.dart';

class ProductDetailGallery extends StatelessWidget {
  const ProductDetailGallery({super.key, required this.images});
  final List<ProductImageModel> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: images.isEmpty
          ? const NetworkImageBox(height: 300, width: double.infinity, fit: BoxFit.contain)
          : PageView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: NetworkImageBox(url: images[index].url, height: 300, width: double.infinity, fit: BoxFit.contain),
              ),
            ),
    );
  }
}

class ProductDetailHeader extends StatelessWidget {
  const ProductDetailHeader({super.key, required this.name, this.shortDescription});
  final String name;
  final String? shortDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        if (shortDescription?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(shortDescription!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.6)),
          ),
      ],
    );
  }
}

class ProductDetailRatingStock extends StatelessWidget {
  const ProductDetailRatingStock({super.key, required this.ratingAverage, required this.ratingCount, required this.stock});
  final num? ratingAverage;
  final int? ratingCount;
  final int stock;

  @override
  Widget build(BuildContext context) {
    final available = stock > 0;
    return Row(
      children: [
        const Icon(Icons.star, size: 19, color: Colors.amber),
        Text(' ${(ratingAverage ?? 0).toStringAsFixed(1)} (${ratingCount ?? 0} نظر)'),
        const Spacer(),
        Text(available ? 'موجود در انبار' : 'ناموجود', style: TextStyle(color: available ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ProductVariantSelector extends StatelessWidget {
  const ProductVariantSelector({super.key, required this.variants, required this.selectedVariantId, required this.onChanged});
  final List<ProductVariantModel> variants;
  final int? selectedVariantId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('انتخاب تنوع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) => ChoiceChip(
            selected: selectedVariantId == variant.id,
            onSelected: variant.stock > 0 ? (_) => onChanged(variant.id) : null,
            label: Text(productVariantLabel(variant)),
          )).toList(),
        ),
      ],
    );
  }
}

class ProductSpecificationsSection extends StatelessWidget {
  const ProductSpecificationsSection({super.key, required this.specifications});
  final List<ProductSpecification> specifications;

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('مشخصات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        ...specifications.asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            color: index.isEven ? scheme.surfaceContainerHighest : scheme.surface,
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(spec.name, style: TextStyle(color: scheme.onSurfaceVariant))),
                Expanded(flex: 3, child: Text(spec.value, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({super.key, required this.description});
  final String? description;

  @override
  Widget build(BuildContext context) {
    if (description?.isNotEmpty != true) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('معرفی محصول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        Text(description!, style: const TextStyle(height: 1.8)),
      ],
    );
  }
}

class ProductDetailBottomBar extends StatelessWidget {
  const ProductDetailBottomBar({super.key, required this.product, required this.selectedPrice, required this.busy, required this.onAddToCart});
  final ProductDetailModel product;
  final num selectedPrice;
  final bool busy;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(color: scheme.surface, boxShadow: const [BoxShadow(blurRadius: 12, offset: Offset(0, -2))]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasDiscount)
                    Text('${money(product.price)} تومان', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                  Text('${money(selectedPrice)} تومان', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w900, fontSize: 17)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onAddToCart,
                child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('افزودن به سبد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String productVariantLabel(ProductVariantModel variant) {
  final values = variant.values.map((value) => '${value.name}: ${value.value}').join('، ');
  return values.isEmpty ? (variant.sku ?? 'تنوع ${variant.id}') : values;
}