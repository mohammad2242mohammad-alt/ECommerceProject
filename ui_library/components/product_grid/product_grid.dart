import 'package:flutter/material.dart';

import '../product_card/product_card.dart';

/// Reusable product grid. Layout and actions are configurable; business rules
/// and data fetching remain outside the UI library.
class ProductGridComponent extends StatelessWidget {
  final List<ProductCardItem> products;
  final ValueChanged<ProductCardItem>? onProductTap;
  final ValueChanged<ProductCardItem>? onFavoriteTap;
  final ValueChanged<ProductCardItem>? onAddToCart;
  final String? title;
  final int columns;
  final double spacing;
  final double runSpacing;
  final double cardWidth;
  final double imageHeight;
  final String currencyLabel;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  const ProductGridComponent({
    super.key,
    required this.products,
    this.onProductTap,
    this.onFavoriteTap,
    this.onAddToCart,
    this.title,
    this.columns = 2,
    this.spacing = 10,
    this.runSpacing = 10,
    this.cardWidth = 190,
    this.imageHeight = 175,
    this.currencyLabel = 'تومان',
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.shrinkWrap = true,
  });

  int _safeColumns() => columns.clamp(1, 6);

  @override
  Widget build(BuildContext context) {
    final count = _safeColumns();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 10),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          Padding(
            padding: padding,
            child: GridView.builder(
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: spacing,
                mainAxisSpacing: runSpacing,
                childAspectRatio: cardWidth / (imageHeight + 235),
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCardComponent(
                  product: product,
                  width: double.infinity,
                  imageHeight: imageHeight,
                  currencyLabel: currencyLabel,
                  onTap: onProductTap == null
                      ? null
                      : () => onProductTap!(product),
                  onFavoriteTap: onFavoriteTap == null
                      ? null
                      : () => onFavoriteTap!(product),
                  onAddToCart: onAddToCart == null
                      ? null
                      : () => onAddToCart!(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
