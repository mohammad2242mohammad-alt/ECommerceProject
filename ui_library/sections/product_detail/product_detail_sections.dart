import 'package:flutter/material.dart';

import '../../components/product_card/product_card.dart';
import '../../components/product_grid/product_grid.dart';
import '../../components/review/review.dart';

/// Reusable Product Detail sections. The page supplies data, navigation and
/// backend-owned business state; sections only compose the UI.
class ProductDetailSections {
  const ProductDetailSections._();

  static Widget hero({required Widget content}) => _Section(child: content);

  static Widget gallery({required Widget content}) => _Section(child: content);

  static Widget priceAndAvailability({required Widget content}) => _Section(child: content);

  static Widget variants({required Widget content}) => _Section(child: content);

  static Widget attributes({required Widget content}) => _Section(child: content);

  static Widget description({required Widget content}) => _Section(child: content);

  static Widget reviews({
    required List<ReviewItem> reviews,
    ValueChanged<ReviewItem>? onReviewTap,
    VoidCallback? onViewAll,
  }) {
    return ReviewComponent(
      reviews: reviews,
      onReviewTap: onReviewTap,
      onViewAll: onViewAll,
    );
  }

  static Widget relatedProducts({
    required List<ProductCardItem> products,
    ValueChanged<ProductCardItem>? onProductTap,
    ValueChanged<ProductCardItem>? onAddToCart,
    ValueChanged<ProductCardItem>? onFavoriteTap,
    String title = 'محصولات مرتبط',
    int columns = 2,
  }) {
    return ProductGridComponent(
      products: products,
      title: title,
      columns: columns,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
      onFavoriteTap: onFavoriteTap,
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;

  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: child,
    );
  }
}
