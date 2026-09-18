import 'package:flutter/material.dart';

import '../../components/product_card/product_card.dart';
import '../../components/product_grid/product_grid.dart';

/// Reusable Search sections. Query state, API calls and filtering logic stay
/// in the page/controller layer.
class SearchSections {
  const SearchSections._();

  static Widget searchBar({required Widget content}) => _Section(child: content);

  static Widget filters({required Widget content}) => _Section(child: content);

  static Widget results({
    required List<ProductCardItem> products,
    ValueChanged<ProductCardItem>? onProductTap,
    ValueChanged<ProductCardItem>? onAddToCart,
    ValueChanged<ProductCardItem>? onFavoriteTap,
    String title = 'نتایج جستجو',
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

  static Widget auxiliary({required Widget content}) => _Section(child: content);
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
